#!/bin/bash

MYSQL_PATH=${MYSQL_INSTALL_PATH}/bin
if [ "$1" = "master" ]
then
  INSTALL_PATH=${BASE_DIR}/master
  DATA_DIR=${BASE_DIR}/data/master
elif [ "$1" = "slave" ]
then
  INSTALL_PATH=${BASE_DIR}/slave
  DATA_DIR=${BASE_DIR}/data/slave
elif [ "$1" = "slave_2" ]
then
  INSTALL_PATH=${BASE_DIR}/slave_2
  DATA_DIR=${BASE_DIR}/data/slave_2
else

  echo "param error !! "
  exit 1;
fi


#if mysql has not start
if [ ! -S ${INSTALL_PATH}/mysql.sock ]
then 
    ######################
    #start mysql
    ######################
	echo "begin to start $1..."
	nohup ${MYSQL_INSTALL_PATH}/bin/mysqld_safe --defaults-file=${INSTALL_PATH}/etc/my.cnf < /dev/null &> ${INSTALL_PATH}/mysqlstart.out &

	i=0
    while [ ! -S ${INSTALL_PATH}/mysql.sock ]
	do 
	    sleep 1; 
		let i++ 
		if [ $i -gt 10 ]
		then
		    echo "$1 start failed. please see the log file '${INSTALL_PATH}/mysqlstart.out'"
			exit 1
		fi
	done
	if [ "$1" = "master" ]
	then
	    MYSQL_PWD=${MASTER_MYSQL_ROOT_PASSWORD} \
        ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${MASTER_PORT} \
                  -e "
                  set global group_replication_bootstrap_group=on;
                  start group_replication;
                  set global group_replication_bootstrap_group=off;
                  "
	elif [ "$1" = "slave" ]
	then
	    MYSQL_PWD=${SLAVE_MYSQL_ROOT_PASSWORD} \
	    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_PORT} \
	    -e "start group_replication;"
	else
	    MYSQL_PWD=${SLAVE_2_MYSQL_ROOT_PASSWORD} \
	    ${MYSQL_PATH}/mysql -u root -h ${HOST_IP} -P ${SLAVE_2_PORT} \
	    -e "start group_replication;"
	    
	fi
	echo "$1 start successfully!"
else
    echo "$1 has already started ! "
fi




