output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances (if applicable)"
  value       = aws_instance.main[*].public_ip
}

output "instance_primary_network_interfaces" {
  description = "Primary network interface IDs"
  value       = aws_instance.main[*].primary_network_interface_id
}

output "security_group_id" {
  description = "ID of the security group"
  value = var.security_group_name != null ? data.aws_security_group.existing[0].id : aws_security_group.app[0].id
}

output "vpc_id" {
  description = "VPC ID where instances are launched"
  value       = data.aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnet IDs where instances are launched"
  value       = data.aws_subnets.available.ids
}

output "ami_id" {
  description = "AMI ID used for instances"
  value       = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  description = "AMI name used for instances"
  value       = data.aws_ami.amazon_linux.name
}

output "instance_type" {
  description = "Instance type of the EC2 instances"
  value       = var.instance_type
}

output "root_volume_ids" {
  description = "Root volume IDs of the instances"
  value       = aws_instance.main[*].root_block_device[0].volume_id
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}
