output "arn" {
  value       = module.kafka.*.arn
  description = "Amazon Resource Name (ARN) of the MSK cluster"
}

output "current_version" {
  value       = module.kafka.*.current_version
  description = "Current version of the MSK Cluster used for updates, e.g. `K13V1IB3VIYZZH`"
}

output "configuration_arn" {
  value       = module.kafka.*.configuration_arn
  description = "Amazon Resource Name (ARN) of the configuration"
}

output "configuration_latest_revision" {
  value       = module.kafka.configuration_latest_revision
  description = "Latest revision of the configuration"
}
