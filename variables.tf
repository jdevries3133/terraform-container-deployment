variable "app_name" {
  type = string
  description = "name of the application, which becomes a kubernetes namespace, and is prepended to kubernetes resources"
}

variable "container" {
  type = string
  name = "fully qualified identifer of the container, like `jdevries3133/container:latest`"
}

variable "domain" {
  type = string
  name = "domain name of the app, which will be put into an ingress_v1 rule"
}

variable "extra_env" {
  type = map(string)
  default = {}
  name = "extra environment variables to pass to the container"
}

variable "replica_count" {
  type = number
  default = 1
  name = "number of replicas in the deployment"
}

variable "application_port" {
  type = number
  default = 80
  name = "port that the application exposes, which you would like to expose to the outside world"
}
