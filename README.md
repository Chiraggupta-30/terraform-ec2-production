# Production-Ready Terraform EC2 Module

A comprehensive, modular Terraform configuration for provisioning AWS EC2 instances with production-grade security, monitoring, and compliance.

## Features

✅ **Data Source Integration**: Dynamically fetches VPCs, subnets, AMIs, and availability zones
✅ **Security Best Practices**: IMDSv2 enforcement, encryption, security group rules
✅ **Monitoring**: CloudWatch integration, detailed monitoring enabled
✅ **High Availability**: Multi-AZ deployment support
✅ **Flexible Configuration**: Extensive variables for customization
✅ **Production Ready**: Auto-recovery, termination protection, proper tagging
✅ **Validation**: Input validation for all critical variables
✅ **Scalability**: Support for multiple instance deployment

## Architecture

```
├── provider.tf          # AWS provider configuration
├── data.tf              # Data sources (VPC, subnets, AMI, etc.)
├── variables.tf         # Variable definitions with validation
├── locals.tf            # Local values and default user data
├── main.tf              # EC2 instance and security group resources
├── outputs.tf           # Output values
├── terraform.tfvars.example  # Example variable values
└── README.md            # This file
```

## Prerequisites

- Terraform >= 1.3.0
- AWS CLI configured with appropriate credentials
- VPC and subnets already created in your AWS account
- EC2 key pair created in your target region (optional)

## Quick Start

### 1. Clone or copy the module

```bash
git clone <repository-url> terraform-ec2-production
cd terraform-ec2-production
```

### 2. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Validate configuration

```bash
terraform validate
terraform plan
```

### 5. Apply configuration

```bash
terraform apply
```

## Variable Reference

### Core Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `ap-south-1` | AWS region for resources |
| `environment` | string | Required | Environment (dev, staging, prod) |
| `project_name` | string | Required | Project name for tagging |

### Instance Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_count` | number | `1` | Number of instances to create (1-10) |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `key_pair_name` | string | `null` | EC2 key pair for SSH access |
| `associate_public_ip` | bool | `false` | Associate public IP address |
| `iam_instance_profile` | string | `null` | IAM instance profile name |

### Storage Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `root_volume_size` | number | `30` | Root volume size in GB (8-1000) |
| `root_volume_type` | string | `gp3` | Root volume type (gp3, gp2, io1) |
| `root_volume_iops` | number | `3000` | IOPS for root volume |
| `root_volume_throughput` | number | `125` | Throughput in MB/s (gp3 only) |

### Security Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `allowed_ssh_cidrs` | list(string) | `["10.0.0.0/8"]` | CIDR blocks for SSH access |
| `allowed_http_cidrs` | list(string) | `["0.0.0.0/0"]` | CIDR blocks for HTTP |
| `allowed_https_cidrs` | list(string) | `["0.0.0.0/0"]` | CIDR blocks for HTTPS |
| `security_group_name` | string | `null` | Use existing security group by name |
| `enable_security_group_creation` | bool | `true` | Create new security group |
| `enable_termination_protection` | bool | `true` | Prevent accidental termination |

### Monitoring & Performance

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_monitoring` | bool | `true` | Enable CloudWatch detailed monitoring |
| `enable_ebs_optimized` | bool | `true` | Enable EBS optimization |
| `enable_auto_recovery` | bool | `true` | Enable automatic recovery |
| `metadata_options` | object | See docs | IMDSv2 configuration |

### VPC & Networking

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpc_name` | string | `default` | VPC name tag to filter |
| `subnet_tags` | map(string) | `{}` | Tags to filter subnets |
| `ami_owner` | string | `amazon` | AMI owner for filtering |
| `ami_name_pattern` | string | `al2023-ami-*` | AMI name pattern |

## Outputs

```hcl
output "instance_ids"                    # EC2 instance IDs
output "instance_private_ips"            # Private IP addresses
output "instance_public_ips"             # Public IP addresses (if applicable)
output "security_group_id"               # Security group ID
output "vpc_id"                          # VPC ID
output "subnet_ids"                      # Subnet IDs
output "ami_id"                          # AMI ID used
output "ami_name"                        # AMI name used
output "root_volume_ids"                 # Root volume IDs
output "aws_account_id"                  # AWS account ID
output "aws_region"                      # AWS region
```

## Data Sources Used

1. **aws_vpc**: Fetch VPC by name tag
2. **aws_availability_zones**: Get available AZs
3. **aws_ami**: Get latest Amazon Linux 2023 AMI
4. **aws_subnets**: Fetch subnets with filtering
5. **aws_security_group**: Lookup existing security group (optional)
6. **aws_ec2_instance_type**: Get instance type details
7. **aws_caller_identity**: Get AWS account ID

## Security Features

### Network Security
- Configurable security groups with granular access control
- IMDSv2 enforcement (prevents SSRF attacks)
- Egress rules for outbound traffic control
- SSH access limited to private IP ranges by default

### Data Protection
- EBS encryption enabled by default
- gp3 volumes for better performance and cost
- Root volume tagging for compliance

### Instance Protection
- Termination protection enabled by default
- Auto-recovery for failed instances
- Detailed CloudWatch monitoring

### Monitoring & Logging
- CloudWatch agent installation
- System log aggregation to CloudWatch
- Default tags for resource tracking

## Example Configurations

### Development Environment (Single Instance)

```hcl
environment = "dev"
project_name = "myapp"
instance_count = 1
instance_type = "t3.micro"
root_volume_size = 30
enable_termination_protection = false
```

### Production Environment (Multi-Instance)

```hcl
environment = "prod"
project_name = "myapp"
instance_count = 3
instance_type = "t3.medium"
root_volume_size = 50
root_volume_type = "gp3"
root_volume_iops = 3000
enable_termination_protection = true
enable_auto_recovery = true
allowed_ssh_cidrs = ["10.0.0.0/8"]
```

### High-Performance Environment (EBS Optimized)

```hcl
environment = "prod"
project_name = "myapp"
instance_type = "c6i.xlarge"
root_volume_type = "io1"
root_volume_size = 100
root_volume_iops = 5000
enable_ebs_optimized = true
```

## State Management (Production)

For production deployments, use S3 remote state:

```hcl
# provider.tf - uncomment the backend section
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "ec2-module/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Create the S3 bucket and DynamoDB table beforehand:

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket terraform-state-prod \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-prod \
  --versioning-configuration Status=Enabled

# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Troubleshooting

### Issue: "VPC not found"

**Solution**: Verify VPC name tag exists and update `vpc_name` variable:

```bash
aws ec2 describe-vpcs --region ap-south-1
```

### Issue: "No subnets found"

**Solution**: Check subnet tags and VPC match:

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxx" --region ap-south-1
```

### Issue: "AMI not found"

**Solution**: Verify AMI name pattern:

```bash
aws ec2 describe-images --owners amazon --filters "Name=name,Values=al2023-ami-*" --region ap-south-1
```

### Issue: "Key pair not found"

**Solution**: Create EC2 key pair:

```bash
aws ec2 create-key-pair --key-name my-ec2-keypair --query 'KeyMaterial' > my-ec2-keypair.pem
chmod 400 my-ec2-keypair.pem
```

## Cost Optimization

- Use `t3.micro` for development (eligible for free tier)
- Use `gp3` volumes instead of `gp2` (more cost-effective)
- Set appropriate volume IOPS and throughput
- Use instance count = 1 for non-critical environments
- Consider Savings Plans for prod environments

## Contributing

Feel free to submit issues and pull requests for improvements.

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
1. Check the Troubleshooting section
2. Review AWS Terraform provider documentation
3. Open an issue in the repository
