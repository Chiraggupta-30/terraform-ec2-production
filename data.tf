# Fetch VPC by name tag
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Fetch availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Fetch subnet with specific tags
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.available.names[0]]
  }

  dynamic "filter" {
    for_each = var.subnet_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

# Fetch existing security group if name is provided
data "aws_security_group" "existing" {
  count  = var.security_group_name != null ? 1 : 0
  name   = var.security_group_name
  vpc_id = data.aws_vpc.main.id
}

# Fetch EC2 launch template for additional configuration options
data "aws_ec2_instance_type" "selected" {
  instance_type = var.instance_type
}

# Fetch current AWS account ID
data "aws_caller_identity" "current" {}
