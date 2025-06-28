# tf-infra-deploy

Terraform deployment for pentesting infrastructure across AWS and Azure.

## Overview

This repository contains Terraform configurations for deploying pentesting infrastructure in AWS and Azure. It provides penetration testers with ready-to-use Kali Linux instances and VPN gateways for conducting authorized security assessments of customer environments.

## Deployment Options

### 1. Pentesting Workstations
- **Single Tester**: Deploy one Kali Linux instance for individual engagements
- **Team Deployment**: Multiple Kali instances for concurrent testing (specify with `tester_count`)
- **Pre-configured**: Kali Linux with standard pentesting tools

### 2. VPN Gateway for Customer Networks
- **Site-to-Site Access**: OpenVPN gateway to connect to customer environments
- **Client Certificates**: Auto-generates certificates for secure connections
- **Team Access**: Multiple testers can connect through single gateway

### 3. Windows Server for Compatibility
- **Exploit Testing**: Test Windows-specific exploits before deployment
- **Tool Compatibility**: Verify tools work on Windows targets
- **PowerShell Testing**: Test PowerShell-based attacks and tools

## Project Structure

```
.
├── environments/          # Environment-specific configurations
│   ├── aws/              # AWS pentesting environment
│   └── azure/            # Azure pentesting environment
├── modules/              # Reusable Terraform modules
│   ├── aws/              # AWS-specific modules
│   │   └── kali-instance/
│   ├── azure/            # Azure-specific modules
│   │   └── kali-vm/
│   └── common/           # Shared modules
│       └── security-groups/
├── main.tf               # Root module configuration
├── variables.tf          # Root module variables
├── outputs.tf            # Root module outputs
└── versions.tf           # Provider version constraints
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured (for AWS deployments)
- Azure CLI configured (for Azure deployments)
- SSH key pair for instance access

## Quick Start

### AWS Deployment

1. Navigate to the AWS environment:
   ```bash
   cd environments/aws
   ```

2. Copy and customize the example variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. Choose your deployment options in `terraform.tfvars`:
   ```hcl
   # Basic setup - just Kali boxes
   tester_count = 3  # Number of Kali instances
   
   # Enable VPN Gateway (optional)
   enable_vpn_gateway = true
   
   # Enable Windows Server (optional)
   enable_windows_server = true
   windows_admin_password = "YourComplexPassword123!"
   windows_server_count = 1
   ```

4. Initialize and deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. Access your resources:
   - **Kali Instances**: Use outputs to get SSH commands
   - **VPN Gateway**: SSH in and retrieve client configs from `/etc/openvpn/clients/`
   - **Windows AD**: RDP to domain controller using private IP through VPN

### Azure Deployment

1. Navigate to the Azure environment:
   ```bash
   cd environments/azure
   ```

2. Copy and customize the example variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. Initialize and deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Common Deployment Scenarios

### Scenario 1: Individual Engagement
```hcl
tester_count = 1
enable_vpn_gateway = true   # Connect to customer network
enable_windows_ad = false
```

### Scenario 2: Red Team Operation
```hcl
tester_count = 5            # Team of 5 testers
enable_vpn_gateway = true   # Shared gateway to target
enable_windows_ad = false
```

### Scenario 3: Windows Exploit Testing
```hcl
tester_count = 2
enable_vpn_gateway = true
enable_windows_server = true    # Test Windows exploits
windows_server_count = 1
```

### Scenario 4: Tool Compatibility Testing
```hcl
tester_count = 1
enable_vpn_gateway = false
enable_windows_server = true    # Test tool compatibility
```

## VPN Client Distribution

When VPN is enabled:

1. SSH to the VPN gateway:
   ```bash
   ssh -i your-key.pem ubuntu@<vpn-gateway-ip>
   ```

2. List available client configs:
   ```bash
   ls /etc/openvpn/clients/
   ```

3. Retrieve a client config:
   ```bash
   sudo cat /etc/openvpn/clients/tester1/tester1.ovpn
   ```

4. Generate additional client configs:
   ```bash
   sudo /root/generate-client.sh customer1
   ```

5. Send the .ovpn file to your customer securely

## Security Considerations

- Always restrict SSH/RDP access to specific IP addresses
- Use strong SSH keys and rotate them regularly
- Deploy in isolated networks/subnets
- Enable encryption for all storage volumes
- Monitor and log all activities
- Destroy resources when testing is complete

## Module Usage

### AWS Kali Instance Module

```hcl
module "kali_instance" {
  source = "../../modules/aws/kali-instance"
  
  name_prefix        = "pentest"
  instance_type      = "t3.medium"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [aws_security_group.kali.id]
  key_name           = aws_key_pair.pentest.key_name
  tags               = local.common_tags
}
```

### Azure Kali VM Module

```hcl
module "kali_vm" {
  source = "../../modules/azure/kali-vm"
  
  name_prefix         = "pentest"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.pentest.name
  vm_size             = "Standard_B2s"
  subnet_id           = azurerm_subnet.public.id
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}
```

## Windows Server for Testing

When Windows server is enabled, you get:

### Use Cases:
- **Windows Exploit Testing**: Test exploits that only work on Windows
- **Tool Compatibility**: Verify Linux tools can attack Windows targets
- **PowerShell Testing**: Test PowerShell Empire, Cobalt Strike, etc.
- **File Transfer Testing**: Test different Windows file transfer methods

### Server Configuration:
- Windows Server 2022 with IIS enabled
- SMB shares configured for testing
- Common Windows services running
- PowerShell execution policy configured for testing
- Windows Defender exclusions for testing directories

### Access Methods:
1. **Through VPN**: RDP to private IP after connecting to VPN
2. **From Kali**: All ports accessible from Kali instances in same VPC

## Cost Optimization

### AWS Pricing Calculation Table

| Resource Type | Instance Type | Hourly Cost | Daily Cost (24h) | Monthly Cost (730h) |
|--------------|---------------|-------------|------------------|---------------------|
| Kali Linux | t3.medium | $0.0416 | $1.00 | $30.37 |
| VPN Gateway | t3.micro | $0.0104 | $0.25 | $7.59 |
| Windows Server | t3.medium | $0.0416 | $1.00 | $30.37 |
| EBS Storage (50GB) | gp3 | - | $0.13 | $4.00 |
| EBS Storage (30GB) | gp3 | - | $0.08 | $2.40 |
| Data Transfer | - | ~$0.09/GB | Variable | Variable |

### Example Monthly Costs for Different Engagements

| Engagement Type | Components | Estimated Monthly Cost |
|-------|------------|------------------------|
| Individual Assessment | 1 Kali + VPN Gateway + storage | $41.96 |
| Small Team Pentest | 3 Kali + VPN Gateway + storage | $111.48 |
| Windows Testing | 2 Kali + VPN + 1 Windows Server + storage | $111.48 |
| Red Team Operation | 5 Kali + VPN + 1 Windows Server + storage | $189.22 |
| Large Engagement | 10 Kali + VPN + 2 Windows Servers + storage | $344.70 |

### Scaling Calculations

**Per Additional Kali Instance**: +$34.37/month
**Per Additional Windows Server**: +$34.37/month

### Cost-Saving Tips:
1. Use `terraform destroy` immediately after engagement completion
2. Schedule automatic shutdowns for long-running assessments
3. Use smaller instance types for reconnaissance-only phases
4. Deploy only required components (use the enable flags)
5. Consider spot instances for non-critical lab testing (up to 70% savings)
6. Spin up infrastructure only when actively testing

## Customization

### Adding More Tools to Kali:
Edit the `user_data` section in `environments/aws/main.tf`:
```bash
user_data = <<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y git tmux metasploit-framework
  # Add your tools here
EOF
```

### Custom VPN Configuration:
Modify VPN settings in `modules/aws/vpn-gateway/variables.tf`

### Different Windows Versions:
Update the AMI filter in `modules/aws/windows-ad/main.tf`

## Important Notes

- These configurations are for authorized penetration testing only
- Always obtain proper written authorization before conducting assessments
- Follow responsible disclosure practices for any vulnerabilities found
- Clean up resources immediately after engagement completion
- Windows server is for compatibility testing only, not production use
- Ensure compliance with all applicable laws and regulations

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

When prompted, type `yes` to confirm destruction of all resources.