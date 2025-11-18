module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "desafio-devops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway = true 
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "desafio-devops-sg" {
  name        = "desafio-devops-sg"
  description = "Security group para desafio devops"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1" 
        cidr_blocks = ["0.0.0.0/0"]
    }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "desafio-devops-instance"
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y docker
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo docker run -d -p 80:80 httpd
                EOF

  vpc_security_group_ids = [aws_security_group.desafio-devops-sg.id ]
  instance_type = "t3.micro"
  monitoring    = true
  subnet_id     = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
