#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters; Please provide unique run identifier, start server number and end server number as the parameters;"
    exit 1
fi

i=1
run=$1
st=$2
end=$3

mkdir -p $run
mkdir -p $run/diff_files
mkdir -p $run/xfsmonkey_logs

num_vms=12

for ip in `cat live_nodes`; do
        echo `date` ------------- Checking for diff file from node $i IP $ip -----------------

        if [ $i -lt $st ] || [ $i -gt $end ]
        then
                i=`expr $i + 1`
                continue
        fi

	port=3022
	for j in `seq 1 $num_vms`; do
		echo `date` ' Pulling from VM '$j' of server '$i'...'
		sshpass -p "password" scp -o "StrictHostKeyChecking no" -P $port user@$ip:~/projects/crashmonkey/diff_results/* $run/diff_files/
		sshpass -p "password" scp -o "StrictHostKeyChecking no" -P $port user@$ip:~/projects/crashmonkey/xfsmonkey*.log $run/xfsmonkey_logs/xfsmonkey_log_server_"$i"_vm_"$j".log
		port=`expr $port + 1`
	done
	i=`expr $i + 1`
done
