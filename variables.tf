variable "container" {
  type        = string
  description = "name of the container image"
}

variable "domain" {
  type        = string
  description = "Public domain name for the application. App pods will be exposed via a service and ingress."
}

/**
 * Used for namespace, and as a prefix for services, pods, etc.
 */
variable "app_name" {
  type        = string
  description = "Name of the application. Used as the namespace, and used as a prefix for other objects. For example, \"appname-service\""
}

/**
 * Application container port that should ultimately be exposed to the outside
 * world.
 */
variable "application_port" {
  type        = number
  default     = 8000
  description = "Port that your pod wants to expose to the outside world."
}

variable "extra_env" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables to add to the ConfigMap injected into the pod environment"
}
