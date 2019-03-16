#!/bin/bash

set -e

# create replication user
MYSQL_PWD=${MYSQL_ROOT_PASSWORD} mysql -u root \
-e "CREATE USER 'slave'@'%' IDENTIFIED BY '123456'; \
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';"

mysql -uslave -h127.0.0.1 -P 3306 -p123456 -e "show master status\G";
