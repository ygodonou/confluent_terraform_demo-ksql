#!/bin/bash 

##### login and list variable




source helper/ccloud.sh

### Variables
URL=https://confluent.cloud 
read -s -p " Enter your confluent password: " PASSWORD
# define the email variables 
# EMAIL=<YEEE@GMAIL.COM>

## Verify that the confluent cli is installed. if not install it

## login into confluent cloud 
ccloud::login_cli

## Delete the KSQLdb Database 
terraform::export_var 
confluent environment use $ENVIRONMENT_ID
KSQLDB=$(confluent ksql cluster list -ojson)
KSQLDB_ID=$(echo $KSQLDB | jq -r '.[].id')
 confluent ksql cluster  delete $KSQLDB_ID   

# delete the schema registry 
confluent schema-registry cluster delete 

terraform destroy 
