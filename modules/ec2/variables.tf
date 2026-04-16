variable "subnet_id" {
  description = "Subnet Id"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
  default     = ""

}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = ""
}

variable "allowed_cidr" {
  description = "Allowed CIDR Blocks"
  type        = list(string)
}

variable "key_output_path" {
  description = "Directory path to save the private key file"
  type        = string
  default     = "."
}
