resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  count         = var.number_of_instances
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  key_name      = var.ami_key_pair_name
  iam_instance_profile = var.instance_role
  associate_public_ip_address = true
} 