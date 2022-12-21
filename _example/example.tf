provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.1"

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
  version = "1.0.1"

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

module "ssh" {
  source      = "clouddrove/security-group/aws"
  version     = "1.0.1"
  name        = "ssh"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block, "0.0.0.0/0"]
  allowed_ports = [22]
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
  broker_node_security_groups = [module.ssh.security_group_ids]

  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

}