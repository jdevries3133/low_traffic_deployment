variable "container" {
  type        = string
  description = "name of the container image"
}

variable "domain" {
  type        = string
  description = "Public domain name for the application. App pods will be exposed via a service and ingress."
}

variable "app_name" {
  type        = string
  description = "Name of the application. Used as the namespace, and used as a prefix for other objects. For example, \"appname-service\""
}

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


variable "storage_size" {
  type        = string
  default     = "1Gi"
  description = "Size of PVC for Postgres data. Bitnami's default is 8Gi, but that's too big for me."
}

variable "startup_probe_path" {
  type        = string
  default     = "/?startupProbe=1"
  description = "URL path for a HTTP readiness check"
}

variable "readiness_timeout" {
  type        = number
  default     = 60
  description = "Readiness check timeout (seconds)"
}
