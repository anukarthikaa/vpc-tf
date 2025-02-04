# Terraform AWS VPC, Subnets, EC2, and Security Groups Setup

This Terraform configuration sets up two Virtual Private Clouds (VPCs), subnets within those VPCs, EC2 instances, and security groups with specific configurations to allow traffic between certain instances and block traffic between others.

## Resources Created

### VPC 1
- **VPC**: CIDR block `10.0.0.0/16`
- **Subnet**: CIDR block `10.0.1.0/24` in `ap-south-1a`
- **EC2 Instance**: `t2.micro` instance with a specific AMI ID in VPC 1 subnet.
- **Security Group**:
  - Allows inbound SSH (port 22) from anywhere (`0.0.0.0/0`).
  - Allows all outbound traffic.

### VPC 2
- **VPC**: CIDR block `10.1.0.0/16`
- **Subnet**: CIDR block `10.1.1.0/24` in `ap-south-1b`
  
#### Security Groups
- **Normal EC2 Instance Security Group** (`vpc2_sg_normal`):
  - Allows inbound SSH (port 22) from anywhere (`0.0.0.0/0`).
  - Allows all outbound traffic.

- **GPU EC2 Instance Security Group** (`vpc2_sg_gpu`):
  - Allows inbound SSH (port 22) from anywhere (`0.0.0.0/0`).
  - Allows inbound traffic from VPC 1's subnet (`10.0.1.0/24`).
  - Allows inbound traffic from VPC 2's subnet (`10.1.1.0/24`).
  - Allows all outbound traffic.

#### EC2 Instances in VPC 2:
- **Normal EC2 Instance** (`vpc2_instance_normal`):
  - `t2.micro` instance with a specific AMI ID in VPC 2 subnet.
  - Attached to `vpc2_sg_normal`.

- **GPU EC2 Instance** (`vpc2_instance_gpu`):
  - `p2.xlarge` instance with a specific AMI ID in VPC 2 subnet.
  - Attached to `vpc2_sg_gpu`.

## Network Communication Rules

1. **EC2 Instances in VPC 1**:
   - The EC2 instance in **VPC 1** is only allowed to receive SSH traffic from the internet (via port 22).
   - It does not have any explicit permissions to interact with instances in **VPC 2**.

2. **EC2 Instances in VPC 2**:
   - The **Normal EC2 Instance** in **VPC 2** can receive traffic only from the internet (via port 22).
   - The **GPU EC2 Instance** in **VPC 2** can receive traffic from:
     - The EC2 instance in **VPC 1** (port 22 for SSH).
     - The **Normal EC2 Instance** in **VPC 2** (any TCP port).
   - The **GPU EC2 Instance** is not directly accessible from the **Normal EC2 Instance**'s security group.
   
3. **Traffic Restrictions**:
   - **EC2 Instance in VPC 1** cannot communicate with **Normal EC2 Instance in VPC 2** directly.
   - **EC2 Instance in VPC 1** can communicate with **GPU EC2 Instance in VPC 2** (as it's allowed in the security group).
   - **Normal EC2 Instance in VPC 2** cannot communicate with **EC2 Instance in VPC 1** or the **GPU EC2 Instance in VPC 2** unless explicitly allowed in their security groups.

## Requirements

- **Terraform**: Version 0.12 or later
- **AWS Credentials**: Ensure you have AWS credentials configured using environment variables or an AWS profile.

## How to Use

1. Clone this repository or copy the Terraform files into your local project.
2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review the execution plan:

   ```bash
   terraform plan
   ```

4. Apply the Terraform configuration to create the resources:

   ```bash
   terraform apply
   ```

5. To destroy the resources:

   ```bash
   terraform destroy
   ```

## Notes

- Be sure to replace the AMI IDs (`ami-0c55b159cbfafe1f0`) with your desired AMIs for the EC2 instances.
- Modify instance types as necessary for your needs.

## Troubleshooting

- If the resources are not being created, check the AWS account limits for VPCs, subnets, EC2 instances, and security groups.
- Ensure your AWS credentials are configured correctly.

## License

This project is licensed under the MIT License.
