variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "initial_node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 3
}