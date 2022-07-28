#!/bin/bash 

## Function to login into confluent 


function ccloud::login_cli(){
  #URL=$1
  #EMAIL=$2
  #PASSWORD=$3

  echo -e "\n# Login"
  OUTPUT=$(
  expect <<END
    log_user 1
    spawn confluent login --url $URL --prompt -vvvv
    expect "Email: "
    send "$EMAIL\r";
    expect "Password: "
    send "$PASSWORD\r";
    expect "Logged in as "
    set result $expect_out(buffer)
END
  )
  echo "$OUTPUT"
  if [[ ! "$OUTPUT" =~ "Logged in as" ]]; then
    echo "Failed to log into your cluster. Please check all parameters and run again."
  fi

  return 0
}

function terraform::run_tf(){
  terraform init 
  terraform validate 
  terraform apply 
}
function terraform::export_var(){
  ENVIRONMENT_ID=$(terraform output environment-id | sed -e 's/"//g')
  CLUSTER_ID=$(terraform output cluster-id | sed -e 's/"//g')
  SA=$(terraform output sa-manager | sed -e 's/"//g')
  SA_KEY=$(terraform output sa-manager_key | sed -e 's/"//g')
  SA_SECRET=$(terraform output sa-manager_secret | sed -e 's/"//g')
  KSQLDB_NAME=ksqldb_demo
}


### Enable Schema registry 
function ccloud::enable_schema_registry() {
  confluent environment use $ENVIRONMENT_ID
  OUTPUT=$(confluent schema-registry cluster enable --cloud $CLOUD_SR --geo $REGION_SR -o json)
  SCHEMA_REGISTRY=$(echo "$OUTPUT" | jq -r ".id")
  SCHEMA_REGISTRY_ENDPOINT=$(echo "$OUTPUT" | jq -r ".endpoint_url")

  echo $SCHEMA_REGISTRY_ENDPOINT

  return 0
}

# Create KSQLDB 


function ccloud::create_ksqldb_app() {
  #KSQLDB_NAME=$1
  #CLUSTER=$2
  # colon deliminated credentials (APIKEY:APISECRET)
  #local ksqlDB_kafka_creds=$3
  #local kafka_api_key=$(echo $ksqlDB_kafka_creds | cut -d':' -f1)
  #local kafka_api_secret=$(echo $ksqlDB_kafka_creds | cut -d':' -f2)

  #KSQLDB=$(confluent ksql cluster create --cluster $CLUSTER --api-key "$kafka_api_key" --api-secret "$kafka_api_secret" --csu 1 -o json "$KSQLDB_NAME" | jq -r ".id")
   #KSQLDB_URL=$(confluent ksql cluster create --cluster $CLUSTER --api-key "$kafka_api_key" --api-secret "$kafka_api_secret" --csu 1 -o json "$KSQLDB_NAME" | jq -r ".id")
  KSQLDB_URL=$(confluent ksql cluster create --cluster $CLUSTER_ID --api-key "$SA_KEY" --api-secret "$SA_SECRET" --csu 1 -o json "$KSQLDB_NAME" | jq -r ".endpoint")
  echo $KSQLDB_URL

  return 0
}
