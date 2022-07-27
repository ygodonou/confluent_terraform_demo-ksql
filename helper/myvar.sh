#!/bin/sh 
WORK=/asdasd/ass
FOO="${VARIABLE:-default}"
cat > var.tf << EOF
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
  other = $ENVIRONMENT
  adawd = $FOO
}
EOF
