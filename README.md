# Confluent Terraform demo  
### Please export the following variables: 

```shell
#TF_VAR_confluent_cloud_api_key=sdfds
#TF_VAR_confluent_cloud_api_secret=asda
#ENVIRONMENT=env-j5zqy8

CLUSTER=ASDADSDA
export CLUSTER_NAME=Demo-cluster
export CLOUD=AWS
export EMAIL=ygodonou+central@confluent.io
export TERRITORY=US
export CLOUD_SR=aws
export REGION_SR=us
export REGION=us-east-1
export AVAILABILITY=SINGLE_ZONE
export ENVIRONMENT=new-env-demo
```

This Script will create the following resource on confluent cloud
- Environment: staging-va
- Kafka cluster :  demo-cluster
- 2 service accounts
    - sa_manager
    - sa_connector
- CLuster Admin RBAC for the Service Account
- ACL for the connectors
- 3 topics
    - clickstream
    - clickstream_codes
    - clickstream_users

- 3 Datagen Sources Connectors 
    - DatagenSourceConnector_clickstream_codes
    - DatagenSourceConnector_clickstream_users
    - DatagenSourceConnector_clickstream

To change the naming of the resource, update the terraform.tfvars file
