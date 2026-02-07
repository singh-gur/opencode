---
name: terraform
description: Terraform/OpenTofu expertise for infrastructure as code, module design, state management, and cloud provider patterns
---

## Terraform / OpenTofu Expertise

Load this skill when writing or reviewing Terraform/OpenTofu configurations, designing modules, or troubleshooting infrastructure issues.

## Core Principles

- **Immutable infrastructure**: Replace rather than modify in-place where possible
- **DRY through modules**: Extract repeated patterns into reusable modules
- **Blast radius control**: Separate state files by environment and domain (network, compute, data)
- **Plan before apply**: Always review `terraform plan` output; automate plan in CI

## HCL Patterns

### Resource Organization
- One resource type per file when files would exceed ~150 lines, otherwise group logically
- Consistent file naming: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `locals.tf`, `data.tf`
- Use `terraform fmt` and `tflint` in CI
- `terraform validate` as pre-commit hook

### Variables & Validation
```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    instance_type = string
    volume_size   = number
    tags          = optional(map(string), {})
  })
}
```

### Locals for Computed Values
```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_name
  }
  # Merge common tags with resource-specific tags
  name_prefix = "${var.project_name}-${var.environment}"
}
```

### Dynamic Blocks
```hcl
# Use dynamic blocks to avoid repetition, but keep them readable
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port   = ingress.value.from_port
    to_port     = ingress.value.to_port
    protocol    = ingress.value.protocol
    cidr_blocks = ingress.value.cidr_blocks
  }
}
```

## Module Design

### Module Structure
```
modules/
  vpc/
    main.tf          # Resources
    variables.tf     # Input variables with descriptions and validation
    outputs.tf       # Outputs for downstream consumption
    versions.tf      # Required providers and terraform version
    README.md        # Auto-generated with terraform-docs
```

### Module Best Practices
- **Narrow scope**: One module = one logical component (VPC, EKS cluster, RDS instance)
- **Explicit inputs**: No hardcoded values; everything configurable via variables
- **Useful outputs**: Expose IDs, ARNs, and endpoints that consumers need
- **Version pinning**: Pin module sources to tags, not branches
- **No providers in modules**: Let the root module configure providers; modules inherit
- **`terraform-docs`**: Auto-generate README from variable/output descriptions

### Module Composition
```hcl
module "vpc" {
  source = "./modules/vpc"
  # Pin community modules to exact versions
  # source  = "terraform-aws-modules/vpc/aws"
  # version = "5.5.1"

  cidr_block  = var.vpc_cidr
  environment = var.environment
}

module "eks" {
  source     = "./modules/eks"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

## State Management

### State Backends
- **S3 + DynamoDB** (AWS): State in S3 with DynamoDB locking - the standard pattern
- **GCS** (GCP): Built-in locking with GCS backend
- **`-backend-config`**: Use partial backend config for environment-specific state
- **Never** commit `.tfstate` files to version control

### State Operations
- **`terraform state list`**: Inventory before making changes
- **`terraform state mv`**: Refactor resource addresses without destroy/recreate
- **`terraform import`**: Bring existing resources under management
- **`terraform state rm`**: Remove from state without destroying (for handoffs)
- **`terraform taint` / `terraform apply -replace`**: Force recreation of a resource

### State Separation Strategy
```
# Separate by environment AND by domain
environments/
  dev/
    network/       # VPC, subnets, NAT
    compute/       # EKS, ASGs
    data/          # RDS, ElastiCache
  prod/
    network/
    compute/
    data/
```

## Provider Patterns

### Version Constraints
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Allow patch updates only
    }
  }
}
```

### Multi-Region / Multi-Account
```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "us_east"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu_west"
}

# Pass provider to module
module "cdn" {
  source = "./modules/cdn"
  providers = {
    aws = aws.us_east  # CloudFront must be in us-east-1
  }
}
```

## Common Patterns

### `for_each` over `count`
- Prefer `for_each` with maps/sets - stable keys prevent destroy/recreate on reorder
- Use `count` only for conditional creation (`count = var.create_resource ? 1 : 0`)

### Data Sources for Existing Resources
```hcl
# Reference existing resources instead of hardcoding IDs
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}
```

### Lifecycle Rules
```hcl
resource "aws_instance" "web" {
  lifecycle {
    create_before_destroy = true        # Zero-downtime replacement
    prevent_destroy       = true        # Protect critical resources
    ignore_changes        = [tags]      # Ignore external tag changes
  }
}
```

## CI/CD Integration

- **Plan on PR**: Run `terraform plan` on every PR, post output as comment
- **Apply on merge**: Apply only from main branch with approval gates
- **Lock files**: Commit `.terraform.lock.hcl` for reproducible provider versions
- **Concourse CI**: Use `terraform` resource type or script tasks with proper state backend config; pipeline per environment with manual trigger for prod apply
- **Drift detection**: Scheduled `terraform plan` to detect out-of-band changes

## Security

- **No secrets in HCL**: Use `data "aws_secretsmanager_secret"` or variable injection
- **Sensitive variables**: Mark with `sensitive = true` to suppress plan output
- **Least privilege IAM**: Terraform runner role should have minimum required permissions
- **`checkov`** or **`tfsec`**: Static analysis for security misconfigurations
- **State encryption**: Enable server-side encryption on state backend

## When to Use This Skill

- Writing or reviewing Terraform/OpenTofu configurations
- Designing module architecture or refactoring existing modules
- Debugging state issues, import workflows, or provider problems
- Setting up Terraform CI/CD pipelines
- Migrating infrastructure between environments or accounts
