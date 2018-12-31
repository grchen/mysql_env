- 功能：在本机建主备

- 前提：hwsql已经安装，make install结束。

- 准备：
  1) 根据环境，修改env.sh
     #如果使用的是hwsql的代码，请设定HWSQL=1
	 #如果使用过是官方mysql的代码，请设定HWSQL=0
	 #如果使用金融版MGR特性，请设定MGR=1
	 #如果使用代码是8.0以上版本，请设定TAG=8.0
  2) 根据需要，修改cnf目录下的master.cnf和slave.cnf
  3) 给当前目录下的文件执行权限。
     chmod -R 777 hwsql
  
- 运行,启动mysql
      bash start.sh
	  #如果data目录下没有文件，初始化之后启动mysql
	  #如果data目录下有文件，仅启动mysql
	  #如果data目录下的文件不整合，请先使用bahs clean.sh清理环境后，执行bash start.sh
	  
- 关闭mysql
    bash stop.sh 
	  
- 清理环境
    bash clean.sh
	
	  

