#!/bin/bash
# if slurm done on hel, and connection over ssh exists
# i want to get a notification


if [[ $1 == "sending" ]]; then
	tmpFile=/wang/users/jgoeltz/cluster_home/.tmp_slurmJobs

	oldState=$(cat $tmpFile)
	state=$(/usr/local/bin/squeue -u jgoeltz -o "%t" --noheader)
	if [ -z "$state" ]; then
		if [[ $oldState == "running" ]] && 
			nc -z 127.0.0.1 1234  ; then
			echo slurmDone | nc 127.0.0.1 1234
			echo noJobs > $tmpFile
			# could send mail with
			# echo "The jobs you have send are now done." | mail -s "All Jobs Done" jgoeltz
		fi
	else
		echo running > $tmpFile
	fi
elif [[ $1 == "receiving" ]]; then
	# wait until dunst is up an running
	# sleep 10
	/usr/bin/notify-send "starting slurmNotifs"
	tmpFun () {
		while IFS= read -r line; do
			if [[ $line == "slurmDone" ]]; then
				/home/julgoe/.local/bin/dunstify -r 6666 -t 3000 "Slurm jobs on hel finished"
			fi
		done
	}
	
	# first check whether nc is already instantiated, if so kill it
	tmp=$(ps axo pid,user,comm,args | grep -v grep | grep "nc -k -l 1234")
	if [ "$(echo $tmp | wc -l)" -ne 0 ]; then
		kill $(echo $tmp | grep -o "^\s*[0-9]*")
	fi
	# important to only be listening from localhost, otherwise anyone can send
	nc -k -l localhost 1234  | tmpFun
else
	echo "must give argument sending/receiving"
fi
