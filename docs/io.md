## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| broker\_node\_client\_subnets | A list of subnets to connect to in client VPC ([documentation](https://docs.aws.amazon.com/msk/1.0/apireference/clusters.html#clusters-prop-brokernodegroupinfo-clientsubnets)) | `list(string)` | `[]` | no |
| broker\_node\_ebs\_volume\_size | The size in GiB of the EBS volume for the data drive on each broker node | `number` | `null` | no |
| broker\_node\_instance\_type | Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large. ([Pricing info](https://aws.amazon.com/msk/pricing/)) | `string` | `null` | no |
| broker\_node\_security\_groups | A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster | `list(string)` | `[]` | no |
| client\_authentication\_sasl\_iam | Enables IAM client authentication | `bool` | `false` | no |
| client\_authentication\_sasl\_scram | Enables SCRAM client authentication via AWS Secrets Manager | `bool` | `false` | no |
| client\_authentication\_tls\_certificate\_authority\_arns | List of ACM Certificate Authority Amazon Resource Names (ARNs) | `list(string)` | `[]` | no |
| cloudwatch\_log\_group\_kms\_key\_id | The ARN of the KMS Key to use when encrypting log data | `string` | `null` | no |
| cloudwatch\_log\_group\_name | Name of the Cloudwatch Log Group to deliver logs to | `string` | `null` | no |
| cloudwatch\_log\_group\_retention\_in\_days | Specifies the number of days you want to retain log events in the log group | `number` | `0` | no |
| cloudwatch\_logs\_enabled | Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs | `bool` | `false` | no |
| configuration\_description | Description of the configuration | `string` | `"Complete example configuration"` | no |
| configuration\_server\_properties | Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html) | `map(string)` | `{}` | no |
| create\_cloudwatch\_log\_group | Determines whether to create a CloudWatch log group | `bool` | `true` | no |
| create\_schema\_registry | Determines whether to create a Glue schema registry for managing Avro schemas for the cluster | `bool` | `true` | no |
| create\_scram\_secret\_association | Determines whether to create SASL/SCRAM secret association | `bool` | `false` | no |
| encryption\_at\_rest\_kms\_key\_arn | You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest | `string` | `null` | no |
| encryption\_in\_transit\_client\_broker | Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`. Default value is `TLS` | `string` | `null` | no |
| encryption\_in\_transit\_in\_cluster | Whether data communication among broker nodes is encrypted. Default value: `true` | `bool` | `null` | no |
| enhanced\_monitoring | Specify the desired enhanced MSK CloudWatch monitoring level. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html) | `string` | `"PER_TOPIC_PER_PARTITION"` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| firehose\_delivery\_stream | Name of the Kinesis Data Firehose delivery stream to deliver logs to | `string` | `null` | no |
| firehose\_logs\_enabled | Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose | `bool` | `false` | no |
| jmx\_exporter\_enabled | Indicates whether you want to enable or disable the JMX Exporter | `bool` | `false` | no |
| kafka\_broker\_number | Kafka brokers per zone | `number` | `1` | no |
| kafka\_version | Version of Kafka brokers | `string` | `"2.2.1"` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| managedby | ManagedBy, eg 'CloudDrove' | `string` | `"hello@clouddrove.com"` | no |
| msk\_cluster\_enabled | Flag to control the msk-cluster creation. | `bool` | `true` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| node\_exporter\_enabled | Indicates whether you want to enable or disable the Node Exporter | `bool` | `false` | no |
| s3\_logs\_bucket | Name of the S3 bucket to deliver logs to | `string` | `null` | no |
| s3\_logs\_enabled | Indicates whether you want to enable or disable streaming broker logs to S3 | `bool` | `false` | no |
| s3\_logs\_prefix | Prefix to append to the folder name | `string` | `null` | no |
| scaling\_max\_capacity | Max storage capacity for Kafka broker autoscaling | `number` | `250` | no |
| scaling\_role\_arn | The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf. This defaults to an IAM Service-Linked Role | `string` | `null` | no |
| scaling\_target\_value | The Kafka broker storage utilization at which scaling is initiated | `number` | `70` | no |
| schema\_registries | A map of schema registries to be created | `map(any)` | `{}` | no |
| schemas | A map schemas to be created within the schema registry | `map(any)` | `{}` | no |
| scram\_secret\_association\_secret\_arn\_list | List of AWS Secrets Manager secret ARNs to associate with SCRAM | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| timeouts | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Amazon Resource Name (ARN) of the MSK cluster |
| configuration\_arn | Amazon Resource Name (ARN) of the configuration |
| configuration\_latest\_revision | Latest revision of the configuration |
| current\_version | Current version of the MSK Cluster used for updates, e.g. `K13V1IB3VIYZZH` |
| scram\_secret\_association\_id | Amazon Resource Name (ARN) of the MSK cluster |
