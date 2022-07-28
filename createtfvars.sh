#!/bin/bash 
#URL="${AVAILABILITY:-SINGLE_ZONE}"
#EMAIL="${AVAILABILITY:-SINGLE_ZONE}"
#PASSWORD="${AVAILABILITY:-SINGLE_ZONE}"
CLOUD="${CLOUD:-AWS}"
REGION="${REGION:-us-east-1}"
AVAILABILITY="${AVAILABILITY:-SINGLE_ZONE}"
CLUSTER_NAME="${CLUSTER_NAME:-demo-cluster}"
ENVIRONMENT="${ENVIRONMENT:-demo-env}"
TERRITORY="${TERRITORY:-US}"

cat > terraform.tfvars << EOF
environment = "$ENVIRONMENT"
cluster_type = "basic"
cluster_name = "$CLUSTER_NAME"
kafka_cluster = {
        display_name = "$CLUSTER_NAME"
        availability = "$AVAILABILITY"
        cloud        = "$CLOUD"
        region       = "$REGION"
    }
# topics lists 
sa_manager = "sa_manager"
role_name = "CloudClusterAdmin"
sa_manager_key = "sa_manager_key"

topics = [
    "clickstream_users",
    "clickstream",
    "clickstream_codes"
]

service_accounts = [
    "app-manager",
    "app-producer",
    "app-consumer"
]
connect_topics = [
    "dlq-lcc",
    "success-lcc",
    "error-lcc",
    "data-preview"
]
sa_connector ="sa_connector"
EOF