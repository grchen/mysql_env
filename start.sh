#!/bin/bash

source env.sh
BASE_DIR=`pwd`
export BASE_DIR


if [ ${MGR} -eq 0 ]
then
	
	#mysql has benn initialized	
    ######################
    #start mysql (no mgr)
    ######################
	cd script/mgr0	
    bash start.sh
else
    ######################
    #start mysql (with mgr)
    ######################
	cd script/mgr1	
    bash start.sh
fi



