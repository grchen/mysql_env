#!/bin/bash

#
# initialize hwsql database
# command-line:
#    bash sbu_init_db master
#           initialize master instance
#    bash sbu_init_db slave
#           initialize slave instance
#    bash sbu_init_db slave_2
#           initialize the second slave instance
#

set -x
######################
# env
######################
if [ "$1" = "master" ]
then
  INSTALL_PATH=${BASE_DIR}/master
  if [ ${HWSQL} -eq 1 ]
  then
      if [[ ${TAG} =~ "8.0" ]]
	  then
          ADD_MYSQL_CNF=${BASE_DIR}/cnf/hwsql/8.0/mgr_master.cnf
	  else
	      ADD_MYSQL_CNF=${BASE_DIR}/cnf/hwsql/mgr_master.cnf
	  fi
  else
      ADD_MYSQL_CNF=${BASE_DIR}/cnf/mysql/master.cnf
  fi
  PORT=${MASTER_PORT}
  DATA_DIR=${BASE_DIR}/data/master
  PASSWORD=${MASTER_MYSQL_ROOT_PASSWORD}
  
elif [ "$1" = "slave" ]
then
  INSTALL_PATH=${BASE_DIR}/slave
  if [ ${HWSQL} -eq 1 ]
  then
      if [[ ${TAG} =~ "8.0" ]]
	  then
          ADD_MYSQL_CNF=${BASE_DIR}/cnf/hwsql/8.0/mgr_slave.cnf
	  else
	      ADD_MYSQL_CNF=${BASE_DIR}/cnf/hwsql/mgr_salve.cnf
	  fi
  else
      ADD_MYSQL_CNF=${BASE_DIR}/cnf/mysql/slave.cnf
  fi
  PORT=${SLAVE_PORT}
  DATA_DIR=${BASE_DIR}/data/slave
  PASSWORD=${SLAVE_MYSQL_ROOT_PASSWORD}
  
elif [ "$1" = "slave_2" ]
then
  INSTALL_PATH=${BASE_DIR}/slave_2
  if [ ${HWSQL} -eq 1 ]
  then
      if [[ ${TAG} =~ "8.0" ]]
	  then
          ADD_MYSQL_CNF=${BASE_DIR}/cnf/hwsql/8.0/mgr_slave_2.cnf
	  else
	      ADD_MYSQL_CNF=${BASE_DIR}/cnf/hwsql/mgr_slave_2.cnf
	  fi
  else
      ADD_MYSQL_CNF=${BASE_DIR}/cnf/mysql/slave_2.cnf
  fi
  PORT=${SLAVE_2_PORT}
  DATA_DIR=${BASE_DIR}/data/slave_2
  PASSWORD=${SLAVE_2_MYSQL_ROOT_PASSWORD}
fi


######################
#make directory
######################
echo "ERASE everyting in ${DATA_DIR} and ${INSTALL_PATH}"
rm -rf ${INSTALL_PATH}
rm -rf ${DATA_DIR}

# data directory
mkdir -p ${DATA_DIR}
if [ $? != "0" ]
then
    echo "error mkdir -p ${DATA_DIR}"
    exit 1
fi

# install directory
mkdir -p ${INSTALL_PATH}
if [ $? != "0" ]
then
    echo "error mkdir -p ${INSTALL_PATH}"
    exit 1
fi

mkdir -p ${INSTALL_PATH}/etc
mkdir -p ${INSTALL_PATH}/var/log
mkdir -p ${INSTALL_PATH}/var/run/mysqld


######################
# create my.cnf file
######################
#mysqld_safe
echo "[mysqld_safe]" > ${INSTALL_PATH}/etc/my.cnf
echo "log-error=${INSTALL_PATH}/var/log/mysqld.log" >> ${INSTALL_PATH}/etc/my.cnf
echo "pid-file=${INSTALL_PATH}/var/run/mysqld/mysqld.pid" >> ${INSTALL_PATH}/etc/my.cnf
echo "" >> ${INSTALL_PATH}/etc/my.cnf

#Add template my.cnf
if [ -n ${ADD_MYSQL_CNF} ] && [ -e ${ADD_MYSQL_CNF} ]; then
cat ${ADD_MYSQL_CNF} >> ${INSTALL_PATH}/etc/my.cnf
fi
echo "" >> ${INSTALL_PATH}/etc/my.cnf

#data path
echo "basedir=${MYSQL_INSTALL_PATH}" >> ${INSTALL_PATH}/etc/my.cnf
echo "datadir=${DATA_DIR}" >> ${INSTALL_PATH}/etc/my.cnf
echo "socket=${INSTALL_PATH}/mysql.sock" >> ${INSTALL_PATH}/etc/my.cnf
if [[ ${TAG} =~ "8.0" ]];then
    echo "mysqlx_socket=${INSTALL_PATH}/mysqlx.sock" >> ${INSTALL_PATH}/etc/my.cnf
fi

echo "port=${PORT}" >> ${INSTALL_PATH}/etc/my.cnf
if [[ ${TAG} =~ "8.0" ]];then
    echo "mysqlx_port=${PORT}0" >> ${INSTALL_PATH}/etc/my.cnf
fi
echo "user=root" >> ${INSTALL_PATH}/etc/my.cnf
echo "secure-file-priv=\"\"" >> ${INSTALL_PATH}/etc/my.cnf


#mgr
echo "" >> ${INSTALL_PATH}/etc/my.cnf
echo "#MGR" >> ${INSTALL_PATH}/etc/my.cnf
if [ ${HWSQL} -eq 1 ]
then
	echo "loose-group-replication-local-address= \"${HOST_IP}:${PORT}1\"">> ${INSTALL_PATH}/etc/my.cnf
    echo "report_host= \"${HOST_IP}\"">> ${INSTALL_PATH}/etc/my.cnf
    echo "loose-group-replication-group-seeds= \"${HOST_IP}:${MASTER_PORT}1,${HOST_IP}:${SLAVE_PORT}1,${HOST_IP}:${SLAVE_2_PORT}1\"">> ${INSTALL_PATH}/etc/my.cnf
else
    echo "transaction_write_set_extraction=XXHASH64" >> ${INSTALL_PATH}/etc/my.cnf
    echo "loose-group_replication_group_name=\"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa\"" >> ${INSTALL_PATH}/etc/my.cnf
    echo "loose-group_replication_start_on_boot=off" >> ${INSTALL_PATH}/etc/my.cnf
    echo "loose-group_replication_local_address= \"${HOST_IP}:${PORT}1\"">> ${INSTALL_PATH}/etc/my.cnf
    echo "loose-group_replication_group_seeds= \"${HOST_IP}:${MASTER_PORT}1,${HOST_IP}:${SLAVE_PORT}1,${HOST_IP}:${SLAVE_2_PORT}1\"">> ${INSTALL_PATH}/etc/my.cnf
    echo "loose-group_replication_bootstrap_group= off" >> ${INSTALL_PATH}/etc/my.cnf
	echo "loose-group-replication-single-primary-mode = ON" >> ${INSTALL_PATH}/etc/my.cnf
fi


######################
# create mysqlcli
######################
echo "${MYSQL_INSTALL_PATH}/bin/mysql --socket=${INSTALL_PATH}/mysql.sock -u root -v " > ${INSTALL_PATH}/mysqlcli
chmod u+x ${INSTALL_PATH}/mysqlcli


######################
#init database
######################
cd ${MYSQL_INSTALL_PATH}
bin/mysqld --defaults-file=${INSTALL_PATH}/etc/my.cnf --basedir=${MYSQL_INSTALL_PATH} --datadir=${DATA_DIR} --initialize-insecure


######################
#start mysqld
######################
echo  "start mysqld"
nohup ${MYSQL_INSTALL_PATH}/bin/mysqld_safe --defaults-file=${INSTALL_PATH}/etc/my.cnf < /dev/null &> ${INSTALL_PATH}/mysqlstart.out &

while [ ! -S ${INSTALL_PATH}/mysql.sock ]
do 
    sleep 1
done


######################
#change password
######################
if [[ ${TAG} =~ "8.0" ]];then
   echo "### Start granting PRIVILEGES for(mysql-8.0) ${local_build_tag} ###"
   ${INSTALL_PATH}/mysqlcli << EOF
   SET SQL_LOG_BIN=0;
   create user 'root'@'%' identified with mysql_native_password by '${PASSWORD}';
   grant all privileges on *.* to 'root'@'%' with grant option;
   ALTER user 'root'@'localhost' IDENTIFIED BY '${PASSWORD}';
   ALTER USER 'root'@'localhost' IDENTIFIED BY '${PASSWORD}' PASSWORD EXPIRE NEVER;
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${PASSWORD}';
   grant all privileges on *.* to 'root'@'localhost' with grant option;
   create user 'root'@'127.0.0.1' identified with mysql_native_password by '${PASSWORD}';
   grant all privileges on *.* to 'root'@'127.0.0.1' with grant option;
   FLUSH PRIVILEGES ;
   SET SQL_LOG_BIN=1;
EOF
else
   echo "### Start granting PRIVILEGES for(mysql-5.6,5.7) ${local_build_tag}  ###"
   ${INSTALL_PATH}/mysqlcli << EOF
   SET SQL_LOG_BIN=0;
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${PASSWORD}' with grant option;
   GRANT ALL PRIVILEGES ON *.* TO 'root'@localhost IDENTIFIED BY '${PASSWORD}' with grant option;
   FLUSH PRIVILEGES ;
   SET SQL_LOG_BIN=1;
EOF
fi 


