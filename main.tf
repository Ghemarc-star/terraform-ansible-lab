# main.tf - LOCAL KIND CLUSTER ONLY

terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "~> 0.0.17"
    }
  }
}

# WALA NG provider "google" BLOCK

resource "kind_cluster" "local" {
  name = "local-cluster"
  
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    
    dynamic "node" {
      for_each = range(var.node_count + 1)
      content {
        role = node.key == 0 ? "control-plane" : "worker"
      }
    }
  }
}

output "cluster_name" {
  value = kind_cluster.local.name
}

output "node_count" {
  value = var.node_count
}