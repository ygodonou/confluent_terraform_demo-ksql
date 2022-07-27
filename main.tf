terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_environment"  "environment" {
  display_name = var.environment
}
resource "confluent_kafka_cluster" "cluster" {
  display_name = var.kafka_cluster["display_name"]
  availability = var.kafka_cluster["availability"]
  cloud        = var.kafka_cluster["cloud"]
  region       = var.kafka_cluster["region"]
  basic {}
  environment {
    id = confluent_environment.environment.id
  }
}

resource "confluent_service_account" "sa_manager" {
  display_name = var.sa_manager
  description  = "Service account to manage Kafka cluster"
}

resource "confluent_role_binding" "iam_rb" {
  principal   = "User:${confluent_service_account.sa_manager.id}"
  role_name   = var.role_name
  crn_pattern = confluent_kafka_cluster.cluster.rbac_crn
}

resource "confluent_api_key" "sa_manager_key" {
  display_name = "sa_manager_key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.sa_manager.id
    api_version = confluent_service_account.sa_manager.api_version
    kind        = confluent_service_account.sa_manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.cluster.id
    api_version = confluent_kafka_cluster.cluster.api_version
    kind        = confluent_kafka_cluster.cluster.kind
    environment {
      id = confluent_environment.environment.id
    }
  }
  depends_on = [
    confluent_role_binding.iam_rb
  ]
}


resource "confluent_kafka_topic" "topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  for_each      = var.topics
  topic_name    = each.value
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

### SA connnectors 


resource "confluent_service_account" "sa_connector" {
  display_name = var.sa_connector
  description  = "Service account to manage Kafka cluster"
}

resource "confluent_kafka_acl" "acl_describe_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}



//for snk Connectors
resource "confluent_kafka_acl" "acl_read_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  for_each      = var.topics
  resource_name = each.value
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

resource "confluent_kafka_acl" "acl_create_connect_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  for_each      = var.connect_topics
  resource_name = each.value
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

resource "confluent_kafka_acl" "acl_write_connect_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  for_each      = var.connect_topics
  resource_name = each.value
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

resource "confluent_kafka_acl" "acl_read-on-connect-lcc-group" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "GROUP"
  resource_name = "connect-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

## Source Connector
resource "confluent_kafka_acl" "acl_write_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  for_each      = var.connect_topics
  resource_name = each.value
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

resource "confluent_kafka_acl" "acl_write_topic_click" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  resource_type = "TOPIC"
  for_each      = var.topics
  resource_name = each.value
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.sa_connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.sa_manager_key.id
    secret = confluent_api_key.sa_manager_key.secret
  }
}

resource "confluent_connector" "clickstream" {
  environment {
    id = confluent_environment.environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_clickstream"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.sa_connector.id
    "kafka.topic"              = "clickstream"
    "output.data.format"       = "JSON"
    "maxInterval"              = "30",
    "quickstart"               = "CLICKSTREAM" 
    "tasks.max"                = "1"
  }

  depends_on = [
    confluent_kafka_acl.acl_describe_cluster,
    confluent_kafka_acl.acl_write_topic,
    confluent_kafka_acl.acl_create_connect_topics,
    confluent_kafka_acl.acl_write_connect_topics,
  ]
}

resource "confluent_connector" "clickstream_users" {
  environment {
    id = confluent_environment.environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_clickstream_users"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.sa_connector.id
    "kafka.topic"              = "clickstream_users"
    "output.data.format"       = "JSON"
    "maxInterval"              = "30",
    "quickstart"               = "CLICKSTREAM_USERS" 
    "tasks.max"                = "1"
  }

  depends_on = [
    confluent_kafka_acl.acl_describe_cluster,
    confluent_kafka_acl.acl_write_topic,
    confluent_kafka_acl.acl_create_connect_topics,
    confluent_kafka_acl.acl_write_connect_topics,
  ]
}

resource "confluent_connector" "clickstream_codes" {
  environment {
    id = confluent_environment.environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_clickstream_codes"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.sa_connector.id
    "kafka.topic"              = "clickstream_codes"
    "output.data.format"       = "JSON"
    "maxInterval"              = "30",
    "quickstart"               = "CLICKSTREAM_CODES" 
    "tasks.max"                = "1"
  }

  depends_on = [
    confluent_kafka_acl.acl_describe_cluster,
    confluent_kafka_acl.acl_write_topic,
    confluent_kafka_acl.acl_create_connect_topics,
    confluent_kafka_acl.acl_write_connect_topics,
    confluent_kafka_acl.acl_write_topic_click
  ]
}

# Create all the service account
#resource "confluent_service_account" "sa_manager" {
#  for_each = var.service_accounts
#  display_name = each.value
#  description  = "Service account to manage 'inventory' Kafka cluster"
#}
