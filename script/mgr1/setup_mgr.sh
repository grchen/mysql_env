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


##################################
# create replication user
##################################
if [[ ${TAG} =~ "8.0" ]];then    
    MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
    -e "set sql_log_bin=0;
	CREATE USER 'mgruser'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'%';
	CREATE USER 'mgruser'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'127.0.0.1';
	CREATE USER 'mgruser'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'localhost';
	set sql_log_bin=1;
	"
else
    MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
    -e "set sql_log_bin=0;
    CREATE USER 'mgruser'@'%' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'%';
    CREATE USER 'mgruser'@'127.0.0.1' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'127.0.0.1';
    CREATE USER 'mgruser'@'localhost' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'localhost';
    FLUSH PRIVILEGES;
    set sql_log_bin=1;
    "
fi

##################################
# set replication user
##################################
MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
-e "change master to 
    master_user='mgruser',
    master_password='123456'
    for channel 'group_replication_recovery';
"

##################################
# init group replication
##################################
MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
-e "install plugin group_replication soname 'group_replication.so';
set global group_replication_bootstrap_group=on;
start group_replication;
set global group_replication_bootstrap_group=off;
"

##################################
# show group status
##################################
MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
-e "select * from performance_schema.replication_group_members ;"



##################################
# check HWSQL slave run status
##################################
while [ ! -S ${BASE_DIR}/slave/mysql.sock ]
do 
    echo "HWSQL slave is unavailable - sleeping"
    sleep 1
done


##################################
# create replication user
##################################
if [[ ${TAG} =~ "8.0" ]];then
    MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
    -e "set sql_log_bin=0;
	CREATE USER 'mgruser'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'%';
	CREATE USER 'mgruser'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'127.0.0.1';
	CREATE USER 'mgruser'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'localhost';
	set sql_log_bin=1;
	"
else
    MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
    -e "set sql_log_bin=0;
    CREATE USER 'mgruser'@'%' IDENTIFIED BY '123456'; \
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'%';
    CREATE USER 'mgruser'@'127.0.0.1' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'127.0.0.1';
    CREATE USER 'mgruser'@'localhost' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'localhost';
    FLUSH PRIVILEGES;
    set sql_log_bin=1;
    "
fi


MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
-e "change master to 
    master_user='mgruser',
    master_password='123456'
    for channel 'group_replication_recovery';
"

##################################
# start group replication
##################################
MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
-e "install plugin group_replication soname 'group_replication.so';
start group_replication;
"

##################################
# show group status
##################################
MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
-e "select * from performance_schema.replication_group_members ;"




##################################
# check HWSQL slave_2 run status
##################################
while [ ! -S ${BASE_DIR}/slave_2/mysql.sock ]
do 
    echo "HWSQL slave_2 is unavailable - sleeping"
    sleep 1
done


##################################
# create replication user
##################################
if [[ ${TAG} =~ "8.0" ]];then
    MYSQL_PWD=${SLAVE_2_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_2_PORT} \
    -e "set sql_log_bin=0;
	CREATE USER 'mgruser'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'%';
	CREATE USER 'mgruser'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'127.0.0.1';
	CREATE USER 'mgruser'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'localhost';
	set sql_log_bin=1;
	"
else
    MYSQL_PWD=${SLAVE_2_MYSQL_ROOT_PASSWORD} \
    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_2_PORT} \
    -e "set sql_log_bin=0;
    CREATE USER 'mgruser'@'%' IDENTIFIED BY '123456'; \
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'%';
    CREATE USER 'mgruser'@'127.0.0.1' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'127.0.0.1';
    CREATE USER 'mgruser'@'localhost' IDENTIFIED BY '123456';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'mgruser'@'localhost';
    FLUSH PRIVILEGES;
    set sql_log_bin=1;
    "
fi


MYSQL_PWD=${SLAVE_2_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_2_PORT} \
-e "change master to 
    master_user='mgruser',
    master_password='123456'
    for channel 'group_replication_recovery';
"

##################################
# start group replication
##################################
MYSQL_PWD=${SLAVE_2_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_2_PORT} \
-e "install plugin group_replication soname 'group_replication.so';
start group_replication;
"


##################################
# show group status
##################################
sleep 3;
MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
-e "select * from performance_schema.replication_group_members ;"



