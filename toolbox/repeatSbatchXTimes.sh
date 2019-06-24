#!/bin/bash

# set -euo pipefail

functionCall='sbatch -p ' # --begin=now+6hours  # if one wants the jobs to start later
# if third argument 
if [ $# -gt 3 ]; then
	functionCall=$functionCall'experiment --wmod '$3' --hicann '$4' '
elif [ $# -gt 2 ]; then
	functionCall=$functionCall'experiment --wmod '$3' '
else
	functionCall=$functionCall'simulation '
fi
functionCall=$functionCall'<(echo -n "#"!; echo /bin/sh; '
# functionCall="echo Hello, World!; cat <(echo sadasdsadasas)"
echo "are you sure you want to submit '"$functionCall"echo "$1"[*repetitions]);' "$2" times?"
read -p "what should be the repetition per job (everything but a number will quit): " numOfFilesPerJob
case $numOfFilesPerJob in
	''|*[!0-9]*) exit ;;
	*) echo continue... ;;
esac
while (( $numOfFilesPerJob > 0 )); do
	functionCall=$functionCall"echo "$1";"
	numOfFilesPerJob=$(($numOfFilesPerJob-1))
done
functionCall=$functionCall');'
#read -p "##### do it (y/Y): " choice
#case "$choice" in 
#  y|Y ) 
#	  echo "   Continuing..."
#	  ;;
#  * ) exit;;
#esac
step=$2
while [ $step -gt 0 ]; do
	eval "${functionCall}"
	step=$(($step - 1))
done

