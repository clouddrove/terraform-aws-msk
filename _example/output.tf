output "arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = module.kafka.arn
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates, e.g. `K13V1IB3VIYZZH`"
  value       = module.kafka.current_version
}

output "configuration_arn" {
  description = "Amazon Resource Name (ARN) of the configuration"
  value       = module.kafka.configuration_arn
}

output "configuration_latest_revision" {
  description = "Latest revision of the configuration"
  value       = module.kafka.configuration_latest_revision
}
