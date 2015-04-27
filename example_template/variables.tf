variable "ami" {
  description = "the AMI to use"
}

variable "count" {
  description = "the number of instances to run"
}

variable "region" {
  description = "the region we are gong to run in"
}

variable "instance_size" {
  description = "EC2 instance size"
  default = "t2.micro"
}

variable "private_subnets" {
  description = "A comma separated list of subnet ids (no spaces)"
}

variable "availability_zones" {
  description = "A comma separated list of availability zones (no spaces)"
}

variable "vpc_id" {
  description = "A vpc id"
}

variable "key_name" {
  description = "The name of the aws key used to launch instances"
}
