locals {
  default_user_data = <<-EOT
    #!/bin/bash
    set -e
    
    # Update system packages
    yum update -y
    
    # Install essential tools
    yum install -y curl wget vim git htop
    
    # Install CloudWatch agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    rpm -U ./amazon-cloudwatch-agent.rpm
    
    # Install SSM agent (already installed on Amazon Linux 2023)
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    
    # Configure CloudWatch logs
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "/aws/ec2/${var.project_name}/${var.environment}",
                "log_stream_name": "{instance_id}-system-logs"
              }
            ]
          }
        }
      }
    }
    EOF
    
    # Start CloudWatch agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    
    # Set timezone
    timedatectl set-timezone Asia/Kolkata
    
    # Disable SELinux for easier management (optional)
    # setenforce 0
    
    # Log successful execution
    echo "User data script completed at $(date)" >> /var/log/user-data.log
  EOT
}
