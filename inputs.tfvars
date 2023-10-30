region = "ap-southeast-2"
tags = {
  Onwer = "del-lza-demo"
}
instance_name       = "del-lza-demo-instance"
instance_type       = "t2.micro"
subnet_id           = "subnet-067f2af2e8f9c8217"
ami_id              = "ami-09b402d0a0d6b112b"
number_of_instances = 2
ami_key_pair_name   = "mykey"
instance_role = "SSMInstanceProfile"