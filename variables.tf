variable "region" {
  default     = "ap-southeast-2"
  description = "AWS region"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "All resources tags: eg: CostCenter, PlatformEnvironment, WorkstreamEnvironment, SupportTeam, SupportTeamEmail, TechnicalServiceOwner and BusinessServiceOwner"
}

variable "instance_name" {
  description = "Name of the instance to be created"
  default     = "awsbuilder-demo"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
  type        = string
}

variable "subnet_id" {
  description = "The VPC subnet the instance(s) will be created in"
  type        = string
}

variable "ami_id" {
  description = "The AMI to use"
  type        = string
}

variable "number_of_instances" {
  description = "Number of instances to be created"
  type        = number
  default     = 2
}


variable "ami_key_pair_name" {
  description = "Name of the Ec2 key pair"
  default     = "tomcat"
  type        = string
}


variable "instance_role" {
  description = "Name of the Ec2 instance profile"
  type        = string
}

