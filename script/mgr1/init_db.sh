#!/bin/bash


######################
#stop mysql if exist
######################
echo "stop the mysql master and slave if exist"
bash sub_stop.sh master
bash sub_stop.sh slave
bash sub_stop.sh slave_2
echo "the mysql master and slave stoped"


######################
#init master
######################
bash sub_init_db.sh  master

######################
#init slave
######################
bash sub_init_db.sh  slave

######################
#init slave_2
######################
bash sub_init_db.sh  slave_2

######################
#setup replcation
######################
bash setup_mgr.sh




  

