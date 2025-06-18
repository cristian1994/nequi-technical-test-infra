#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

docker run -d \
  -e DB_HOST=${rds_endpoint} \
  -e DB_NAME=${db_name} \
  -e DB_USER=${db_user} \
  -e DB_PASSWORD=${db_password} \
  -p 8080:8080 \
  ccarmona9402/technical-test-api:v1
