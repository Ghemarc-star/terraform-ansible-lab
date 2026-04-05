# variables.tf
variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "project_id" {
  description = "GCP Project ID (not used locally)"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP Region (not used locally)"
  type        = string
  default     = ""
}