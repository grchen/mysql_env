#!/bin/bash


DATA_DIR=${BASE_DIR}/data/master
file_num=`ls ${DATA_DIR} | wc -l`
if [ ${file_num} -gt 0 ]
then
	
	#mysql has benn initialized	
    ######################
    #start mysql
    ######################
	echo "begin to start master and slave..."
		
    bash sub_start.sh master
	bash sub_start.sh slave
		    
	echo "master and slave start successfully! "
else
    ######################
    #initialize mysql
    ######################
	echo "begin to initialize and start mysql..."
		
	bash init_db.sh
		
    echo "mysql initialize and start successfully! "
fi





