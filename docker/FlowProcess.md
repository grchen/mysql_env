1. docker下载mysql
docker pull mysql

2. 
准备两个主备配置文件位于
/Users/grchen/work/mysql/master/my.cnf
[mysqld]
## 设置server_id，一般设置为IP，同一局域网内注意要唯一
server_id=100  
## 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog-ignore-db=mysql  
## 开启二进制日志功能，可以随便取，最好有含义（关键就是这里了）
log-bin=edu-mysql-bin  
## 为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存
binlog_cache_size=1M  
## 主从复制的格式（mixed,statement,row，默认格式是statement）
binlog_format=mixed  
## 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
expire_logs_days=7  
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062

/Users/grchen/work/mysql/slave/my.cnf
[mysqld]
## 设置server_id，一般设置为IP,注意要唯一
server_id=101  
## 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog-ignore-db=mysql  
## 开启二进制日志功能，以备Slave作为其它Slave的Master时使用
log-bin=edu-mysql-slave1-bin  
## 为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存
binlog_cache_size=1M  
## 主从复制的格式（mixed,statement,row，默认格式是statement）
binlog_format=mixed  
## 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
expire_logs_days=7  
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062  
## relay_log配置中继日志
relay_log=edu-mysql-relay-bin  
## log_slave_updates表示slave将复制事件写进自己的二进制日志
log_slave_updates=1  
## 防止改变数据(除了特殊的线程)
read_only=1

3. docker运行两个容器：
docker run --name mysql_master -v /Users/grchen/work/mysql/master:/etc/mysql/conf.d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:latest
docker run --name mysql_slave -v /Users/grchen/work/mysql/slave:/etc/mysql/conf.d -p 3307:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:latest

4. 登录到master
mysql -uroot -h127.0.0.1 -P 3306 -p123456

运行：
stop master;
CREATE USER 'slave'@'%' IDENTIFIED BY '123456';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';  
start master;

show master status\G;
记录下Position位置和file名称
*************************** 1. row ***************************
             File: edu-mysql-bin.000003
         Position: 1661
     Binlog_Do_DB:
 Binlog_Ignore_DB: mysql
Executed_Gtid_Set:
1 row in set (0.00 sec)


推出客户端后然后在用刚才创建的账号登录下master：
mysql -uslave -h127.0.0.1 -P 3306 -p123456

4.登录到slave
下面的 master_log_pos=1480填写上面从master查询出来的数字，master_log_file同样

mysql -uroot -h127.0.0.1 -P 3307 -p123456

stop slave;

CREATE USER 'slave'@'%' IDENTIFIED BY '123456';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';  

change master to master_host='172.17.0.2', master_user='slave', master_password='123456', master_port=3306, master_log_file='edu-mysql-bin.000003', master_log_pos=1480, master_connect_retry=30;
start slave;
show slave status;

5. 验证：
登录master创建一个数据库或者表，查看Position
登录slave上查看Position，看是否为一致，如果是一致，同步过程OK

show tables;






