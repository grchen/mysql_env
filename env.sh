# image tag
TAG=5.7

HOST_IP="127.0.0.1"
MASTER_MYSQL_ROOT_PASSWORD=123456
SLAVE_MYSQL_ROOT_PASSWORD=123456
SLAVE_2_MYSQL_ROOT_PASSWORD=123456
MASTER_PORT=3306
SLAVE_PORT=3307
SLAVE_2_PORT=3308
MYSQL_INSTALL_PATH=/usr/local/mysql


# if hwsql,set 1   
# if mysql,set 0 
HWSQL=1 

#MGR MODE
MGR=0


export HOST_IP
export MASTER_MYSQL_ROOT_PASSWORD
export SLAVE_MYSQL_ROOT_PASSWORD
export MASTER_PORT
export SLAVE_PORT
export MYSQL_INSTALL_PATH
export TAG
export HWSQL
export MGR
export SLAVE_2_MYSQL_ROOT_PASSWORD
export SLAVE_2_PORT


