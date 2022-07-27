environment = "staging-va"
cluster_type = "basic"
cluster_name = "demo-cluster"
kafka_cluster = {
        display_name = "demo-cluster"
        availability = "SINGLE_ZONE"
        cloud        = "AWS"
        region       = "us-east-1"
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
    "yg-app-manager",
    "yg-app-producer",
    "yg-app-consumer"
]
connect_topics = [
    "dlq-lcc",
    "success-lcc",
    "error-lcc",
    "data-preview"
]
sa_connector ="sa_connector"
