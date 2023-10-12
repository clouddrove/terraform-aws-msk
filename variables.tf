variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'"
}

variable "kafka_version" {
  type        = string
  default     = "2.2.1"
  description = "Version of Kafka brokers"
}

variable "kafka_broker_number" {
  type        = number
  default     = 1
  description = "Kafka brokers per zone"
}

variable "broker_node_instance_type" {
  type        = string
  default     = null
  description = "Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large. ([Pricing info](https://aws.amazon.com/msk/pricing/))"
}

variable "broker_node_ebs_volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node"
  type        = number
  default     = null
}

variable "broker_node_client_subnets" {
  type        = list(string)
  default     = []
  description = "A list of subnets to connect to in client VPC ([documentation](https://docs.aws.amazon.com/msk/1.0/apireference/clusters.html#clusters-prop-brokernodegroupinfo-clientsubnets))"
}

variable "broker_node_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster"
}

variable "msk_cluster_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the msk-cluster creation."
}

variable "configuration_description" {
  type        = string
  default     = "Complete example configuration"
  description = "Description of the configuration"
}

variable "configuration_server_properties" {
  type        = map(string)
  default     = {}
  description = "Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)"
}

variable "enhanced_monitoring" {
  type        = string
  default     = "PER_TOPIC_PER_PARTITION"
  description = "Specify the desired enhanced MSK CloudWatch monitoring level. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)"
}

variable "client_authentication_tls_certificate_authority_arns" {
  type        = list(string)
  default     = []
  description = "List of ACM Certificate Authority Amazon Resource Names (ARNs)"
}

variable "client_authentication_sasl_scram" {
  type        = bool
  default     = false
  description = "Enables SCRAM client authentication via AWS Secrets Manager"
}

variable "client_authentication_sasl_iam" {
  type        = bool
  default     = false
  description = "Enables IAM client authentication"
}

variable "encryption_in_transit_client_broker" {
  type        = string
  default     = null
  description = "Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`. Default value is `TLS`"
}

variable "encryption_in_transit_in_cluster" {
  type        = bool
  default     = null
  description = "Whether data communication among broker nodes is encrypted. Default value: `true`"
}

variable "encryption_at_rest_kms_key_arn" {
  type        = string
  default     = null
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest"
}

variable "jmx_exporter_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable the JMX Exporter"
}

variable "node_exporter_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable the Node Exporter"
}

variable "cloudwatch_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs"
  type        = bool
  default     = false
}

variable "firehose_logs_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose"
}

variable "firehose_delivery_stream" {
  type        = string
  default     = null
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to"
}

variable "s3_logs_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable streaming broker logs to S3"
}

variable "s3_logs_bucket" {
  type        = string
  default     = null
  description = "Name of the S3 bucket to deliver logs to"
}

variable "s3_logs_prefix" {
  type        = string
  default     = null
  description = "Prefix to append to the folder name"
}

variable "timeouts" {
  type        = map(string)
  default     = {}
  description = "Create, update, and delete timeout configurations for the cluster"
}

variable "create_cloudwatch_log_group" {
  type        = bool
  default     = true
  description = "Determines whether to create a CloudWatch log group"
}

variable "cloudwatch_log_group_name" {
  type        = string
  default     = null
  description = "Name of the Cloudwatch Log Group to deliver logs to"
}

variable "create_scram_secret_association" {
  type        = bool
  default     = false
  description = "Determines whether to create SASL/SCRAM secret association"
}

variable "scram_secret_association_secret_arn_list" {
  type        = list(string)
  default     = [""]
  description = "List of AWS Secrets Manager secret ARNs to associate with SCRAM"
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  default     = 0
  description = "Specifies the number of days you want to retain log events in the log group"
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  default     = null
  description = "The ARN of the KMS Key to use when encrypting log data"
}

variable "scaling_max_capacity" {
  type        = number
  default     = 250
  description = "Max storage capacity for Kafka broker autoscaling"
}

variable "scaling_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf. This defaults to an IAM Service-Linked Role"
}

variable "scaling_target_value" {
  type        = number
  default     = 70
  description = "The Kafka broker storage utilization at which scaling is initiated"
}

variable "create_schema_registry" {
  type        = bool
  default     = true
  description = "Determines whether to create a Glue schema registry for managing Avro schemas for the cluster"
}

variable "schema_registries" {
  type        = map(any)
  default     = {}
  description = "A map of schema registries to be created"
}

variable "schemas" {
  type        = map(any)
  default     = {}
  description = "A map schemas to be created within the schema registry"
}
