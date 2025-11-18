output "ec2_instance_ip" {
    description = "The public IP address of the EC2 instance"
    value       = "O ip do ec2 é ${module.ec2_instance.public_ip}"
}