variable "region" {
  default     = "ap-southeast-2"
  description = "AWS region"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "All resources tags: eg: CostCenter, PlatformEnvironment, WorkstreamEnvironment, SupportTeam, SupportTeamEmail, TechnicalServiceOwner and BusinessServiceOwner"
}


variable "subnet_id" {
  description = "The VPC subnet the instance(s) will be created in"
  type        = string
}


variable "patch_groups" {
  description = "Patch groups names "
}


variable "vault_name" {
  description = "The name of a logical container where backups are stored"
  type        = string
}