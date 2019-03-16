#!/bin/bash

# check mysql master run status

set -e

until MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} mysql -u root -h 172.10.10.1 ; do
  >&2 echo "MySQL master is unavailable - sleeping"
  sleep 3
done

mysql -uslave -h172.10.10.1 -P 3306 -p123456 -e "show master status\G";

# create replication user

MYSQL_PWD=${MYSQL_ROOT_PASSWORD} mysql -u root \
-e "CREATE USER 'slave'@'%' IDENTIFIED BY '123456'; \
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';"

# get master log File & Position

master_status_info=$(MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} mysql -u root -h 172.10.10.1 -e "show master status\G")

LOG_FILE=$(echo "${master_status_info}" | awk 'NR!=1 && $1=="File:" {print $2}')
LOG_POS=$(echo "${master_status_info}" | awk 'NR!=1 && $1=="Position:" {print $2}')

# set node master

MYSQL_PWD=${MYSQL_ROOT_PASSWORD} mysql -u root \
-e "CHANGE MASTER TO MASTER_HOST='172.10.10.1', \
MASTER_USER='slave', \
MASTER_PASSWORD='123456', \
MASTER_LOG_FILE='${LOG_FILE}', \
MASTER_LOG_POS=${LOG_POS};"


# start slave and show slave status

MYSQL_PWD=${MYSQL_ROOT_PASSWORD} mysql -u root -e "START SLAVE;show slave status\G"

# start slave and show slave status
