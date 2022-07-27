output "resource-ids" {
  value = <<-EOT
  Environment ID:   ${confluent_environment.environment.id}
  Kafka Cluster ID: ${confluent_kafka_cluster.cluster.id}
  EOT

}

output "environment-id" {
    value = confluent_environment.environment.id
}

output "cluster-id" {
    value = confluent_kafka_cluster.cluster.id
}

output "sa-manager" {
    value = confluent_service_account.sa_manager.id
}
output "sa-manager_key" {
    value = confluent_api_key.sa_manager_key.id
}

output "sa-manager_secret" {
    value = confluent_api_key.sa_manager_key.secret
    sensitive = true
}