provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.1"

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_enabled                               = true
  cidr_block                                = "10.0.0.0/16"
  enable_flow_log                           = false
  additional_cidr_block                     = ["172.3.0.0/16", "172.2.0.0/16"]
  enable_dhcp_options                       = false
  dhcp_options_domain_name                  = "service.consul"
  dhcp_options_domain_name_servers          = ["127.0.0.1", "10.10.0.2"]
  enabled_ipv6_egress_only_internet_gateway = false
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  nat_gateway_enabled = true
  single_nat_gateway  = true

  name        = "subnets"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id                          = module.vpc.vpc_id
  type                            = "public-private"
  igw_id                          = module.vpc.igw_id
  cidr_block                      = module.vpc.vpc_cidr_block
  ipv6_cidr_block                 = module.vpc.ipv6_cidr_block
  assign_ipv6_address_on_creation = false

}

module "http-https" {
  source      = "clouddrove/security-group/aws"
  version     = "1.3.0"
  name        = "http-https"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [80, 443]
}

module "ssh" {
  source      = "clouddrove/security-group/aws"
  version     = "1.3.0"
  name        = "ssh"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block, "0.0.0.0/0"]
  allowed_ports = [22]
}

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "1.3.0"

  name        = "clouddrove-secure-bucket"
  environment = "test"
  attributes  = ["private"]
  label_order = ["name", "environment"]

  versioning = true
  acl        = "private"
}

module "kms_key" {
  source                  = "clouddrove/kms/aws"
  version                 = "1.3.0"
  name                    = "kms"
  environment             = "test"
  label_order             = ["environment", "name"]
  enabled                 = true
  description             = "KMS key for kafka"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/kafka"
  policy                  = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

}

module "secrets_manager" {
  source                  = "clouddrove/secrets-manager/aws"
  version                 = "1.3.0"
  name        = "secrets-manager"
  environment = "test"
  label_order = ["name", "environment"]

  secrets = [
    {
      name                    = "AmazonMSK_1"
      description             = "My secret 1"
      recovery_window_in_days = 7
      kms_key                 = module.kms_key.key_id
      secret_string           = "{ \"username\": \"test-user\", \"password\": \"test-password\" }"
    }
  ]
}

module "kafka" {
  source = ".././"

  name        = "kafka"
  environment = "test"
  label_order = ["name", "environment"]

  kafka_version       = "2.7.1"
  kafka_broker_number = 3

  broker_node_client_subnets  = module.subnets.private_subnet_id
  broker_node_ebs_volume_size = 20
  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = [module.ssh.security_group_ids, module.http-https.security_group_ids]

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

  jmx_exporter_enabled    = true
  node_exporter_enabled   = true
  cloudwatch_logs_enabled = true
  s3_logs_enabled         = true
  s3_logs_bucket          = module.s3_bucket.id
  s3_logs_prefix          = "logs/msk-"

  scaling_max_capacity = 512
  scaling_target_value = 80

  client_authentication_sasl_scram         = false
  create_scram_secret_association          = false
  scram_secret_association_secret_arn_list = [module.secrets_manager.secret_arns]

  schema_registries = {
    team_a = {
      name        = "team_a"
      description = "Schema registry for Team A"
    }
    team_b = {
      name        = "team_b"
      description = "Schema registry for Team B"
    }
  }
  schemas = {
    team_a_tweets = {
      schema_registry_name = "team_a"
      schema_name          = "tweets"
      description          = "Schema that contains all the tweets"
      compatibility        = "FORWARD"
      schema_definition    = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"}, {\"name\": \"f2\", \"type\": \"string\"} ]}"
    }
  }
}