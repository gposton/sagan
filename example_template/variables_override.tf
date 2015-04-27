variable "ami" {
  description = "the AMI to use"
  default = "ami-2593a715"
}

variable "count" {
  description = "the number of instances to run"
  default = "3"
}

variable "region" {
  description = "the region we are gong to run in"
  default = "us-west-2"
}

variable "instance_size" {
  description = "EC2 instance size"
  default = "t2.micro"
}

variable "private_subnets" {
  description = "A comma separated list of subnet ids (no spaces)"
  default = "subnet-682f9c1f,subnet-2672ef43,subnet-ff9243a6"
}

variable "availability_zones" {
  description = "A comma separated list of availability zones (no spaces)"
  default = "us-west-2a,us-west-2b,us-west-2c"
}

variable "vpc_id" {
  description = "A vpc id"
  default = "vpc-464acf23"
}

variable "key_name" {
  description = "The name of the aws key used to launch instances"
  default = "ClearCareVPC"
}
