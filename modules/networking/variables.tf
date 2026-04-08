variable "vpc_cidr" {
    description = "The CIDR block for the VPC."
    type        = string
}

variable "vpc_name" {
    description = "The name of the VPC."
    type        = string
    default     = ""
}

variable "private_subnet" {
    description = "The CIDR block for the private subnet."
    type        = string
    default     = ""
}

variable "tags" {
    description = "A map of tags to add to all resources."
    type        = map(string)
    default     = {}
}

variable "availability_zone" {
    description = "Availability Zone"
    type        = string
    default = ""
}