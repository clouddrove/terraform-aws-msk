module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

resource "aws_msk_cluster" "msk-cluster" {
  count                  = var.msk_cluster_enabled ? 1 : 0
  cluster_name           = format("%s-mks-cluster", module.labels.id)
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_broker_number
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = var.broker_node_client_subnets
    ebs_volume_size = var.broker_node_ebs_volume_size
    instance_type   = var.broker_node_instance_type
    security_groups = var.broker_node_security_groups
  }

  configuration_info {
    arn      = join("", aws_msk_configuration.this.*.arn)
    revision = join("", aws_msk_configuration.this.*.latest_revision)
  }

  tags = module.labels.tags
}

resource "aws_msk_configuration" "this" {
  count             = var.msk_cluster_enabled ? 1 : 0
  name              = format("%s-configuration", module.labels.id)
  description       = var.configuration_description
  kafka_versions    = [var.kafka_version]
  server_properties = join("\n", [for k, v in var.configuration_server_properties : format("%s = %s", k, v)])
}