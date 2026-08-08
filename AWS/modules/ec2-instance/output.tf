output "PublicIP-of-instance" {
    value = aws_instance.ec2_instance1.public_ip
}