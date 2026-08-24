# aws-java-3tier

Terraform configuration for a multi-AZ, three-tier AWS architecture: a public-facing application load balancer, an auto-scaled application tier in private subnets, and an isolated database tier.

> **Status: work in progress.** The networking, security, and compute layers are implemented. The database tier and the ALB listener are not yet built — see [Roadmap](#roadmap) before deploying.

## Architecture

```
                        Internet
                            │
                    ┌───────▼────────┐
                    │ Internet GW    │
                    └───────┬────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │   Public subnets (one per AZ)         │
        │   ┌─────────┐          ┌─────────┐    │
        │   │   ALB   │          │   NAT   │    │
        │   └────┬────┘          └────┬────┘    │
        └────────┼────────────────────┼─────────┘
                 │ alb_sg             │
        ┌────────▼────────────────────▼─────────┐
        │   Private subnets (one per AZ)        │
        │   ┌─────────────────────────────┐     │
        │   │  Auto Scaling Group          │     │
        │   │  Ubuntu 22.04 / spot         │     │
        │   └──────────────┬──────────────┘     │
        └──────────────────┼────────────────────┘
                           │ app_sg
        ┌──────────────────▼────────────────────┐
        │   Database tier (db_sg — not yet      │
        │   provisioned, see Roadmap)           │
        └───────────────────────────────────────┘
```

Traffic flows in one direction only. Each tier's security group accepts traffic exclusively from the tier above it, referenced by security group ID rather than CIDR block, so the rules stay correct as instance IPs change.

## Modules

| Module | Provisions |
|---|---|
| `modules/networking` | VPC with DNS support, public and private subnets across N availability zones, internet gateway, one NAT gateway per AZ with Elastic IPs, and route tables with associations |
| `modules/security` | Three chained security groups (ALB → app → database), an EC2 IAM role with CloudWatch Agent and Secrets Manager access, and the matching instance profile |
| `modules/compute` | Application load balancer, target group with a `/health` check, launch template using the latest Canonical Ubuntu 22.04 AMI, and an Auto Scaling Group across the private subnets |

## Design decisions

**One NAT gateway per availability zone.** A single shared NAT gateway is cheaper but creates a single point of failure and generates cross-AZ data transfer charges. Per-AZ gateways keep egress traffic within its own zone.

**Security group chaining over CIDR rules.** `app_sg` allows inbound traffic only from `alb_sg`, and `db_sg` only from `app_sg`. Referencing security groups by ID means the rules remain valid regardless of how instances are scheduled or re-addressed.

**IMDSv2 enforced.** The launch template sets `http_tokens = "required"` and a hop limit of 1, which blocks the SSRF-to-credential-theft path that made IMDSv1 a common breach vector.

**Spot instances.** The launch template requests spot capacity to keep the cost of a demonstration environment low. This is not a production-appropriate default without a mixed instances policy and interruption handling.

**Latest AMI resolved at plan time.** A data source filters for the most recent Canonical Ubuntu 22.04 image rather than pinning an AMI ID, so the configuration stays portable across regions.

## Prerequisites

- Terraform >= 1.0
- AWS provider ~> 6.0 (pinned in `provider.tf`)
- AWS credentials with permissions to create VPC, EC2, ELB, IAM, and Auto Scaling resources
- Deploys to `us-east-1` (currently hardcoded in `provider.tf`)

## Usage

Create a `terraform.tfvars` file:

```hcl
vpc_cidr_block = "10.0.0.0/16"
az_count       = 2
app_port       = 8080
db_port        = 5432
instance_type  = "t3.micro"
```

Then:

```bash
terraform init
terraform plan
terraform apply
```

Tear down when finished — NAT gateways and the ALB bill hourly whether or not traffic flows through them:

```bash
terraform destroy
```

## Inputs

| Name | Type | Description |
|---|---|---|
| `vpc_cidr_block` | `string` | CIDR block for the VPC. Subnets are carved from this with `cidrsubnet(cidr, 8, index)` |
| `az_count` | `number` | Number of availability zones to span. Determines subnet count |
| `app_port` | `number` | Port the application listens on. Opened in `app_sg` from the ALB only |
| `db_port` | `number` | Database port. Opened in `db_sg` from the app tier only |
| `instance_type` | `string` | EC2 instance type for the application tier |

## Outputs

| Name | Description |
|---|---|
| `vpc` | VPC ID |
| `availability_zones` | Availability zones selected for this deployment |
| `public_subnet_cidr` | Public subnet IDs |
| `private_subnet_cidr` | Private subnet IDs |
| `Elastic_ip` | Public IPs of the NAT gateway Elastic IPs |
| `aws_target_group_arn` | Launch template ARN |

## Roadmap

Known gaps, in the order they need addressing:

- [ ] **ALB listener.** The load balancer and target group exist but are not connected. Without an `aws_lb_listener` forwarding to the target group, no traffic reaches the application tier.
- [ ] **Application bootstrap.** `user_data` is commented out in the launch template, so instances boot without an application. The ELB health check on `/health` will fail and the ASG will cycle instances indefinitely.
- [ ] **Target group port.** Hardcoded to 80 while `app_sg` opens `var.app_port`. These must agree.
- [ ] **Database tier.** `db_sg` is defined but no RDS instance is provisioned. Adding a Multi-AZ RDS instance in a dedicated subnet group completes the third tier.
- [ ] **Pin private subnet AZs.** Private subnets do not set `availability_zone`, but private route tables assume subnet index matches NAT gateway index. Pin both to the same AZ list to avoid cross-AZ NAT charges.
- [ ] **Use `az_count` consistently.** NAT gateways and Elastic IPs are hardcoded to `count = 2` instead of deriving from `az_count`.
- [ ] **Remove public IP association.** The launch template sets `associate_public_ip_address = true` while placing instances in private subnets, where it has no effect.
- [ ] **Scope the Secrets Manager policy.** `SecretsManagerReadWrite` grants account-wide write access. Replace with an inline policy limited to `secretsmanager:GetSecretValue` on specific ARNs.
- [ ] **Thread `env-prefix` from the root module.** It defaults to `dev` inside each module and is never overridden, so all resources are named `dev-*` regardless of environment.
- [ ] **Use `name_prefix` for security groups and IAM roles.** Hardcoded names prevent deploying twice into the same account and region.
- [ ] **Remote state backend.** State is local. An S3 backend with DynamoDB locking is required for any collaborative use.
- [ ] **Parameterize the region.** Currently hardcoded to `us-east-1` in `provider.tf`.
