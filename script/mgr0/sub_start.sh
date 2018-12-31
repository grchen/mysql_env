#!/bin/bash


if [ "$1" = "master" ]; then
  INSTALL_PATH=${BASE_DIR}/master
  DATA_DIR=${BASE_DIR}/data/master
elif [ "$1" = "slave" ]; then
  INSTALL_PATH=${BASE_DIR}/slave
  DATA_DIR=${BASE_DIR}/data/slave
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
	echo "$1 start successfully!"
else
    echo "$1 has already started ! "
fi




