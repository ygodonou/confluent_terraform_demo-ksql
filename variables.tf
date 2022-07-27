variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}


variable "environment" {
  description = "Confluent Cloud API Secret"
  type        = string
}
variable "cluster_name" {
    description = "Confluent Cloud API Key (also referred as Cloud API ID)"
    type        = string
    default = "aws_demo_cluster"
}

variable "cluster_type" {
    description = "Confluent Cloud API Key (also referred as Cloud API ID)"
    type        = string
    default = "standard"
}

variable "kafka_cluster"  {
    description = "Confluent Cloud API Key (also referred as Cloud API ID)"
    type        = map(string) 
    default     = {
        display_name = "inventory"
        availability = "SINGLE_ZONE"
        cloud        = "AWS"
        region       = "us-east-2"
    }

}

variable topics {
  type        = set(string)
  description = "list of topics to create"
}

variable "service_accounts" {
  type        = set(string)
  description = "list of service accounts to create"
}

variable "sa_manager" {
  type        = string
  description  = "Service account to manage Kafka cluster"
}

variable "role_name" {
  type        = string
  description = "role type"
}

variable "connect_topics" {
  type        = set(string)
  description = "role type"
}



variable "sa_connector" {
  type        = string
  description = "description"
}