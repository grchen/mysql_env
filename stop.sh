#!/bin/bash

source env.sh
BASE_DIR=`pwd`
export BASE_DIR


if [ ${MGR} -eq 0 ]
then
	
	#mysql has benn initialized	
    ######################
    #stop mysql (no mgr)
    ######################
	cd script/mgr0	
    bash stop.sh
else
    ######################
    #stop mysql (with mgr)
    ######################
	cd script/mgr1	
    bash stop.sh
fi



