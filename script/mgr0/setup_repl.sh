#!/bin/bash


set -x

MYSQL_PATH=${MYSQL_INSTALL_PATH}/bin


##################################
# check HWSQL master run status
##################################
while [ ! -S ${BASE_DIR}/master/mysql.sock ]
do 
    echo "HWSQL master is unavailable - sleeping"
    sleep 1
done


MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -uroot -h${HOST_IP} -P ${MASTER_PORT} -e "show master status\G";


##################################
# create replication user
##################################
if [[ ${TAG} =~ "8.0" ]];then
    MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
    -e "CREATE USER 'slave'@'%' IDENTIFIED WITH mysql_native_password BY '123456'; 
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';"
else
    MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
    -e "CREATE USER 'slave'@'%' IDENTIFIED BY '123456'; 
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';
	CREATE USER 'slave'@'127.0.0.1' IDENTIFIED BY '123456'; 
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'127.0.0.1';"
fi

##################################
# get master log File & Position
##################################
master_status_info=$(MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} -e "show master status\G")

LOG_FILE=$(echo "${master_status_info}" | awk 'NR!=1 && $1=="File:" {print $2}')
LOG_POS=$(echo "${master_status_info}" | awk 'NR!=1 && $1=="Position:" {print $2}')

##################################
# check HWSQL slave run status
##################################
while [ ! -S ${BASE_DIR}/slave/mysql.sock ]
do 
    echo "HWSQL slave is unavailable - sleeping"
    sleep 1
done


##################################
# set node master
##################################
if [ ${HWSQL} -eq 1 ]
then
	if [[ ${TAG} =~ "8.0" ]]
	  then
          MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
          -e "CHANGE MASTER TO MASTER_HOST='${HOST_IP}', 
          MASTER_USER='slave', 
          MASTER_PASSWORD='123456', 
          MASTER_LOG_FILE='${LOG_FILE}', 
          MASTER_LOG_POS=${LOG_POS};"
	  else
	      MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
          -e "CHANGE MASTER TO MASTER_HOST='${HOST_IP}', 
          MASTER_USER='slave', 
          MASTER_PASSWORD='123456', 
          MASTER_AUTO_POSITION=1;"
	  fi 
    
else
    MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
    -e "CHANGE MASTER TO MASTER_HOST='${HOST_IP}', 
    MASTER_USER='slave', 
    MASTER_PASSWORD='123456', 
    MASTER_LOG_FILE='${LOG_FILE}', 
    MASTER_LOG_POS=${LOG_POS};"
fi

##################################
# start slave and show slave status
##################################
sleep 3;
MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
-e "START SLAVE;
show slave status\G"


