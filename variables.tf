# variables.tf - LOCAL LAB ONLY

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}