module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

locals {
  cloudwatch_log_group = var.msk_cluster_enabled && var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].name : var.cloudwatch_log_group_name
}
#tfsec:ignore:aws-msk-enable-logging
resource "aws_msk_cluster" "msk-cluster" {
  count                  = var.msk_cluster_enabled ? 1 : 0
  cluster_name           = module.labels.id
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_broker_number
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = var.broker_node_client_subnets
    instance_type   = var.broker_node_instance_type
    security_groups = var.broker_node_security_groups
    storage_info {
      ebs_storage_info {
        volume_size = var.broker_node_ebs_volume_size
      }
    }
  }

  dynamic "client_authentication" {
    for_each = (
      (
        var.client_authentication_tls_certificate_authority_arns != null &&
        length(var.client_authentication_tls_certificate_authority_arns) > 0
      ) ||
      (var.client_authentication_sasl_scram != null) ||
      (var.client_authentication_sasl_iam != null) ||
      (var.client_authentication_unauthenticated != null)
    ) ? [1] : []

    content {
      dynamic "tls" {
        for_each = (
          var.client_authentication_tls_certificate_authority_arns != null &&
          length(var.client_authentication_tls_certificate_authority_arns) > 0
        ) ? [1] : []

        content {
          certificate_authority_arns = var.client_authentication_tls_certificate_authority_arns
        }
      }

      sasl {
        iam   = var.client_authentication_sasl_iam != null ? var.client_authentication_sasl_iam : false
        scram = var.client_authentication_sasl_scram != null ? var.client_authentication_sasl_scram : false
      }

      unauthenticated = var.client_authentication_unauthenticated != null ? var.client_authentication_unauthenticated : false
    }
  }
  
  # Ignore empty tls{} block to avoid unnecessary drifts from AWS-managed state
  lifecycle {
    ignore_changes = [
      client_authentication[0].tls
    ]
  }


  configuration_info {
    arn      = join("", aws_msk_configuration.this[*].arn)
    revision = join("", aws_msk_configuration.this[*].latest_revision)
  }

  encryption_info {
    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.node_exporter_enabled
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.cloudwatch_logs_enabled
        log_group = var.cloudwatch_logs_enabled ? local.cloudwatch_log_group : null
      }
      firehose {
        enabled         = var.firehose_logs_enabled
        delivery_stream = var.firehose_delivery_stream
      }
      s3 {
        enabled = var.s3_logs_enabled
        bucket  = var.s3_logs_bucket
        prefix  = var.s3_logs_prefix
      }
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
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

resource "aws_msk_scram_secret_association" "this" {
  count = var.msk_cluster_enabled && var.create_scram_secret_association && var.client_authentication_sasl_scram ? 1 : 0

  cluster_arn     = aws_msk_cluster.msk-cluster[0].arn
  secret_arn_list = var.scram_secret_association_secret_arn_list
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.msk_cluster_enabled && var.create_cloudwatch_log_group ? 1 : 0

  name              = format("%s-cloudwatch", module.labels.id)
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = module.labels.tags
}

resource "aws_appautoscaling_target" "this" {
  count = var.msk_cluster_enabled ? 1 : 0

  max_capacity       = var.scaling_max_capacity
  min_capacity       = 1
  role_arn           = var.scaling_role_arn
  resource_id        = aws_msk_cluster.msk-cluster[0].arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  service_namespace  = "kafka"
}

resource "aws_appautoscaling_policy" "this" {
  count = var.msk_cluster_enabled ? 1 : 0

  name               = "${var.name}-broker-storage-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_msk_cluster.msk-cluster[0].arn
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    target_value = var.scaling_target_value
  }
}

resource "aws_glue_registry" "this" {
  for_each = var.msk_cluster_enabled && var.create_schema_registry ? var.schema_registries : {}

  registry_name = each.value.name
  description   = lookup(each.value, "description", null)

  tags = module.labels.tags
}

resource "aws_glue_schema" "this" {
  for_each = var.msk_cluster_enabled && var.create_schema_registry ? var.schemas : {}

  schema_name       = each.value.schema_name
  description       = lookup(each.value, "description", null)
  registry_arn      = aws_glue_registry.this[each.value.schema_registry_name].arn
  data_format       = "AVRO"
  compatibility     = each.value.compatibility
  schema_definition = each.value.schema_definition

  tags = module.labels.tags
}