variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 50
    error_message = "Project name must be between 1 and 50 characters."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = can(regex("^t3|t4|m5|m6|c5|c6", var.instance_type))
    error_message = "Instance type must be from t3, t4, m5, m6, c5, or c6 families."
  }
}

variable "ami_owner" {
  description = "AMI owner filter (amazon, self, etc.)"
  type        = string
  default     = "amazon"
}

variable "ami_name_pattern" {
  description = "AMI name pattern to search for"
  type        = string
  default     = "al2023-ami-*"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 1000
    error_message = "Root volume size must be between 8 and 1000 GB."
  }
}

variable "root_volume_type" {
  description = "Root volume type (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp3", "gp2", "io1"], var.root_volume_type)
    error_message = "Root volume type must be gp3, gp2, or io1."
  }
}

variable "root_volume_iops" {
  description = "IOPS for root volume (only for gp3 and io1)"
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Throughput for root volume in MB/s (only for gp3)"
  type        = number
  default     = 125
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "enable_termination_protection" {
  description = "Enable termination protection"
  type        = bool
  default     = true
}

variable "enable_ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

variable "associate_public_ip" {
  description = "Associate public IP address"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "VPC name tag to filter"
  type        = string
  default     = "default"
}

variable "subnet_tags" {
  description = "Tags to filter subnets"
  type        = map(string)
  default     = {}
}

variable "security_group_name" {
  description = "Security group name to filter"
  type        = string
  default     = null
}

variable "enable_security_group_creation" {
  description = "Create a new security group if not found"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0
    error_message = "At least one SSH CIDR block must be specified."
  }
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "user_data" {
  description = "Bootstrap script to execute on instance launch"
  type        = string
  default     = null
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_auto_recovery" {
  description = "Enable automatic recovery for instance"
  type        = bool
  default     = true
}

variable "metadata_options" {
  description = "Customize IMDSv2 metadata options"
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
  })
  default = {}
}
