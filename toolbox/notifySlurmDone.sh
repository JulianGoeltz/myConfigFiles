#!/bin/bash
# if slurm done on hel, and connection over ssh exists
# i want to get a notification

set -euo pipefail

port=1234
codeword=slurmDone

if [ $# -eq 0 ]; then
	echo "needs argument"
elif [[ $1 == "sending" ]]; then
	tmpFile=/wang/users/jgoeltz/cluster_home/.tmp_slurmJobs

	oldState=$(cat $tmpFile)
	state=$(/usr/local/bin/squeue -u jgoeltz -o "%t" --noheader 2>/dev/null)
	if [ -z "$state" ]; then
		if [[ $oldState == "running" ]] && 
			nc -z 127.0.0.1 "$port"  ; then
			echo noJobs > $tmpFile
			echo $codeword | nc -N 127.0.0.1 "$port"
			# could send mail with
			# echo "The jobs you have send are now done." | mail -s "All Jobs Done" jgoeltz
		fi
	else
		echo running > $tmpFile
	fi
elif [[ $1 == "receiving" ]]; then
	# wait until dunst is up an running
	# sleep 10
	dunstify "starting slurmNotifs"
	tmpFun () {
		while IFS= read -r line; do
			if [[ $line == "$codeword" ]]; then
				dunstify -r 6666 -t 3000 "Slurm jobs on hel finished"
				# cvlc ~/Music/bell.mp3 vlc://quit &
			fi
		done
	}
	
	exact_call="nc -k -l localhost $port"
	# first check whether nc is already instantiated, if so kill it
	if pgrep -u julgoe -f "$exact_call" >/dev/null ; then
		kill "$(pgrep -u julgoe -f "$exact_call")"
	fi
	# important to only be listening from localhost, otherwise anyone can send
	eval "$exact_call"  | tmpFun
else
	echo "must give argument sending/receiving"
fi
