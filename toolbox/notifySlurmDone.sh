#!/bin/bash
# if slurm done on hel, and connection over ssh exists
# i want to get a notification

# set -euo pipefail

port=1234

if [[ $1 == "sending" ]]; then
	tmpFile=/wang/users/jgoeltz/cluster_home/.tmp_slurmJobs

	oldState=$(cat $tmpFile)
	state=$(/usr/local/bin/squeue -u jgoeltz -o "%t" --noheader 2>/dev/null)
	if [ -z "$state" ]; then
		if [[ $oldState == "running" ]] && 
			nc -z 127.0.0.1 "$port"  ; then
			echo slurmDone | nc 127.0.0.1 "$port"
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
	
	exact_call="nc -k -l localhost $port"
	# first check whether nc is already instantiated, if so kill it
	tmp=$(pgrep -u julgoe -f "$exact_call")
	if [ "$(echo "$tmp" | wc -l)" -ne 0 ]; then
		kill "$tmp"
	fi
	# important to only be listening from localhost, otherwise anyone can send
	eval "$exact_call"  | tmpFun
else
	echo "must give argument sending/receiving"
fi
