#!/bin/bash
#!/bin/bash

# Source library
source helper/ccloud.sh

### Variables
URL=https://confluent.cloud 
read -s -p " Enter your confluent password: " PASSWORD
# define the email variables 
# EMAIL=<YEEE@GMAIL.COM>

## Verify that the confluent cli is installed. if not install it

## login into confluent cloud 
ccloud::login_cli

#### ZRun the terraform 
./createtfvars.sh
terraform::run_tf
terraform::export_var 

#### run KSQLDB and Enable Schema registry 

ccloud::enable_schema_registry
ccloud::create_ksqldb_app


