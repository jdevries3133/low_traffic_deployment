variable "container" {
  type = string
}

variable "domain" {
  type = string
}

/**
 * Used for namespace, and as a prefix for services, pods, etc.
 */
variable "app_name" {
  type = string
}

/**
 * Application container port that should ultimately be exposed to the outside
 * world.
 */
variable "application_port" {
  type    = number
  default = 8000
}
