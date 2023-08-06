# Define a Terraform variable to store the host IP address or CIDR block
variable "host_ip" {
  type    = string
  default = "54.226.218.101/32" # Set the default value to "54.226.218.101/32" if no value is provided
}

variable "user_data" {
  type    = string
  default = "IyEvYmluL2Jhc2gKCnN1ZG8geXVtIHVwZGF0ZSAteQpzdWRvIHl1bSB1cGdyYWRlIC15CnN1ZG8geXVtIGluc3RhbGwgaHR0cGQgLXkKc3VkbyBzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IGh0dHBkCg=="
}

variable "vpc_id" {
  type    = string
  default = "vpc-0c89411b70a35fac0"
}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "subnets" {
  type    = list(any)
  default = ["subnet-0654912976c52a494", "subnet-0e8da6d08a1ac4d6e"]
}