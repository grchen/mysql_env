#!/bin/bash



if [ "$1" = "master" ]; then
  INSTALL_PATH=${BASE_DIR}/master
  PASSWORD="${MASTER_MYSQL_ROOT_PASSWORD}"
elif [ "$1" = "slave" ]; then
  INSTALL_PATH=${BASE_DIR}/slave
  PASSWORD="${SLAVE_MYSQL_ROOT_PASSWORD}"
elif [ "$1" = "slave_2" ]; then
  INSTALL_PATH=${BASE_DIR}/slave_2
  PASSWORD="${SLAVE_2_MYSQL_ROOT_PASSWORD}"
else
  echo "param error !! "
  exit 1;
fi


#if mysql alive
if [  -S ${INSTALL_PATH}/mysql.sock ]
then 
    ######################
    #stop mysql
    ######################
	echo "begin to stop $1... "
    ${MYSQL_INSTALL_PATH}/bin/mysqladmin --socket=${INSTALL_PATH}/mysql.sock -u root -p${PASSWORD} shutdown
	echo "$1 stop successfully! "
else
    echo "$1 has stopped !"
fi



