#!/bin/bash

functionCall='sbatch -p '
# if third argument 
if [ $# -gt 2 ]; then
	functionCall=$functionCall'experiment --wmod '$3' '
else
	functionCall=$functionCall'simulation '
fi
functionCall=$functionCall'<(echo -n "#"!; echo /bin/sh; echo '
functionCall=$functionCall$1
functionCall=$functionCall');'
# functionCall="echo Hello, World!; cat <(echo sadasdsadasas)"
echo "are you sure you want to submit '"$functionCall"' "$2" times?"
read -p "##### do it (y/Y): " choice
case "$choice" in 
  y|Y ) 
	  echo "   Continuing..."
	  ;;
  * ) exit;;
esac
step=$2
while [ $step -gt 0 ]; do
	eval "${functionCall}"
	step=$(($step - 1))
done

