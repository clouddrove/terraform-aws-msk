output "arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = try(aws_msk_cluster.msk-cluster[0].arn, "")
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates, e.g. `K13V1IB3VIYZZH`"
  value       = try(aws_msk_cluster.msk-cluster[0].current_version, "")
}

output "configuration_arn" {
  description = "Amazon Resource Name (ARN) of the configuration"
  value       = try(aws_msk_configuration.this[0].arn, "")
}

output "configuration_latest_revision" {
  description = "Latest revision of the configuration"
  value       = try(aws_msk_configuration.this[0].latest_revision, "")
}