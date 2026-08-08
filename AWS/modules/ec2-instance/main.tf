resource "aws_instance" "ec2_instance1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

}
