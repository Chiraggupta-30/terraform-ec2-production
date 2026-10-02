# Create security group if not found
resource "aws_security_group" "app" {
  count       = var.enable_security_group_creation && var.security_group_name == null ? 1 : 0
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} ${var.environment}"
  vpc_id      = data.aws_vpc.main.id

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-sg"
    }
  )
}

# SSH ingress rule
resource "aws_security_group_rule" "ssh" {
  count             = var.enable_security_group_creation && var.security_group_name == null ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  security_group_id = aws_security_group.app[0].id

  description = "SSH access"
}

# HTTP ingress rule
resource "aws_security_group_rule" "http" {
  count             = var.enable_security_group_creation && var.security_group_name == null ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_http_cidrs
  security_group_id = aws_security_group.app[0].id

  description = "HTTP access"
}

# HTTPS ingress rule
resource "aws_security_group_rule" "https" {
  count             = var.enable_security_group_creation && var.security_group_name == null ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_https_cidrs
  security_group_id = aws_security_group.app[0].id

  description = "HTTPS access"
}

# Egress rule (allow all outbound traffic)
resource "aws_security_group_rule" "egress" {
  count             = var.enable_security_group_creation && var.security_group_name == null ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app[0].id

  description = "All outbound traffic"
}

# EC2 Instance
resource "aws_instance" "main" {
  count                = var.instance_count
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = data.aws_subnets.available.ids[count.index % length(data.aws_subnets.available.ids)]
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_pair_name
  user_data            = base64encode(coalesce(var.user_data, local.default_user_data))

  # Security group selection
  vpc_security_group_ids = [
    var.security_group_name != null ? data.aws_security_group.existing[0].id : aws_security_group.app[0].id
  ]

  # Root volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = contains(["gp3", "io1"], var.root_volume_type) ? var.root_volume_iops : null
    throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = "${var.project_name}-${var.environment}-root-vol-${count.index + 1}"
    }
  }

  # Instance metadata options (IMDSv2 enforced)
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint != null ? var.metadata_options.http_endpoint : "enabled"
    http_tokens                 = var.metadata_options.http_tokens != null ? var.metadata_options.http_tokens : "required"
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit != null ? var.metadata_options.http_put_response_hop_limit : 1
    instance_metadata_tags      = "enabled"
  }

  # Monitoring and protection
  monitoring                  = var.enable_monitoring
  associate_public_ip_address = var.associate_public_ip
  disable_api_termination     = var.enable_termination_protection
  ebs_optimized               = var.enable_ebs_optimized

  # CPU credits (T3 instances only)
  credit_specification {
    cpu_credits = "unlimited"
  }

  # Auto recovery
  instance_initiated_shutdown_behavior = "stop"

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-${count.index + 1}"
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [
    aws_security_group.app
  ]
}

# Enable auto-recovery through EC2 API
resource "aws_ec2_instance_state" "main" {
  count       = var.enable_auto_recovery ? var.instance_count : 0
  instance_id = aws_instance.main[count.index].id
  state       = "running"
}
