variable "app_name" {
  type = string
}

variable "container" {
  type = string
}

variable "domain" {
  type = string
}

variable "extra_env" {
  type = map(string)
  default = {}
}

variable "replica_count" {
  type = number
  default = 1
}

variable "application_port" {
  type = number
  default = 80
}
