#!/bin/bash

source env.sh
BASE_DIR=`pwd`
export BASE_DIR

cd script/mgr1
######################
#stop hwsql
######################
echo "stop the hwsql master and slave if exist"
bash sub_stop.sh master
bash sub_stop.sh slave
bash sub_stop.sh slave_2
echo "the hwsql master and slave stoped"

cd ../../
######################
#clear env
######################
rm -rf master/*
rm -rf slave/*
rm -rf slave_2/*
rm -rf data/master/*
rm -rf data/slave/*
rm -rf data/slave_2/*
echo "env is cleaned!"

