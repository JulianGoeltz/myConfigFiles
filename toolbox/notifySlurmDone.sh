#!/bin/bash
# if slurm done on hel, and connection over ssh exists
# i want to get a notification


if [[ $1 == "sending" ]]; then
	tmpFile=/wang/users/jgoeltz/cluster_home/.tmp_slurmJobs

	oldState=$(cat $tmpFile)
	state=$(/usr/local/bin/squeue -u jgoeltz -o "%t" --noheader)
	if [ -z $state ]; then
		if [[ $oldState == "running" ]]; then
			echo slurmDone | nc 127.0.0.1 1234
			echo noJobs > $tmpFile
		fi
	else
		echo running > $tmpFile
	fi
elif [[ $1 == "receiving" ]]; then
	# wait until dunst is up an running
	sleep 10
	/usr/bin/notify-send "starting slurmNotifs"
	echo something
	tmpFun () {
		while IFS= read -r line; do
			notify-send "reading line $line"
			if [[ $line == "slurmDone" ]]; then
				/home/julgoe/.local/bin/dunstify -r 6666 -t 3000 "Slurm jobs on hel finished"
			fi
		done
	}
	nc -k -l 1234  | tmpFun
else
	echo "must give argument sending/receiving"
fi
