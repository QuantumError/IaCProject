
variable "namespace" {
  description = "Kubernetes namespace both sites are deployed into"
  type        = string
  default     = "webfront"
}

variable "create_namespace" {
  description = "Whether this module should create the namespace (set false if it already exists / is managed elsewhere)"
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Number of nginx pod replicas per site"
  type        = number
  default     = 1
}

variable "nginx_image" {
  description = "nginx image used to serve the static files"
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "site1_name" {
  description = "Release/app name for site 1"
  type        = string
  default     = "site1"
}

variable "site1_source_dir" {
  description = "Directory (relative to this module) containing site 1's static files"
  type        = string
  default     = "../website"
}

variable "site1_node_port" {
  description = "NodePort site 1 is exposed on (30000-32767)"
  type        = number
  default     = 30080
}

variable "site2_name" {
  description = "Release/app name for site 2"
  type        = string
  default     = "site2"
}

variable "site2_source_dir" {
  description = "Directory (relative to this module) containing site 2's static files"
  type        = string
  default     = "../website2"
}

variable "site2_node_port" {
  description = "NodePort site 2 is exposed on (30000-32767)"
  type        = number
  default     = 30081
}
