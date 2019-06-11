#!/bin/bash

RED='\033[0;31m'
ORANGY='\033[0;33m'
NC='\033[0m'

IFS=$'\n'
for job in $(squeue -p "experiment" --sort=-t,u --noheader -o "%i %u %M %T" "$@"); do
	job_id=$(echo "$job" | awk '{print $1;}')
	job_user=$(echo "$job" | awk '{print $2;}')
	[[ $job_user == "$USER" ]] && job_user="${RED}${USER}${NC}" || job_user="${ORANGY}${job_user}${NC}"
	job_time=$(echo "$job" | awk '{print $3;}')
	job_status=$(echo "$job" | awk '{print $4;}')
	tmpString=$(scontrol show jobid "$job_id" -dd)
	job_name=$(echo "$tmpString" | /wang/environment/software/jessie/spack/20180129_live/views/developmisc_426/bin/pcregrep -M "BatchScript=(.|\n)*" | grep -oP "\S*\.(yaml|hdf5)\S*")
	if [ -n "$job_name" ]; then
		if [[ "$(echo "$job_name" | wc -l)" -eq 1 ]]; then
			if echo "$job_name" | grep -q yaml; then
				job_name=", $(basename "$(dirname "$job_name")")/$(basename "$job_name")"
			else
				job_name=", $(basename "$job_name")"
			fi
		elif [[ "$(echo "$job_name" | wc -l)" -eq 0 ]]; then
			job_name=""
		else
			job_name=", $(echo $job_name | wc -l) files"
		fi
	else
		job_name=""
	fi
	echo -en "Job $job_id ($job_status $job_time$job_name)\n    by $job_user has "
	tmpString=$(echo "$tmpString" | grep -o --color=never "Licenses=[WFB,0-9]*")
	if [[ "${#tmpString}" -gt 40 ]]; then
		echo "${tmpString::40}..."
	else
		echo "$tmpString"
	fi | grep --color=always "W[0-9]*"
 done
# redo previous change
unset IFS
