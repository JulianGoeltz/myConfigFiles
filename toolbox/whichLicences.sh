#!/bin/bash

# set -euo pipefail

RED='\033[0;31m'
ORANGY='\033[0;33m'
NC='\033[0m'

fileTmpScontrol=~/.tmp_scontrol2.sh

jobsRunning=""
jobsPending=""

IFS=$'\n'
# for job in $(squeue -p "experiment" --sort=-t,u --noheader -o "%i %u %M %T" "$@"); do
for jobinfo in $(scontrol show -o job); do
	echo $jobinfo | grep -vqP "Partition=(exp|longexp|calib)" && continue
	job_id=$(echo "$jobinfo" | grep -oP "JobId=\K[0-9]*")

	job_status=$(echo "$jobinfo" | grep -oP "JobState=\K\S*")
	# only include running/pending jobs
	echo "$job_status" | grep -vqP "RUNNING|PENDING" && continue
	job_status=$(printf '%7s' "$job_status")

	job_user=$(echo "$jobinfo" | grep -oP "UserId=\K[^\(]*")
	job_user=$(printf '%10s' "$job_user")
	job_user=${job_user:0:10}
	if echo "$job_user" | grep -q "$USER" ; then
		job_user="${RED}${job_user}${NC}"

		scontrol write batch_script "$job_id" $fileTmpScontrol >/dev/null
		job_name=$([ -f $fileTmpScontrol ] && grep -oP "\S*\.(yaml|hdf5)\S*" $fileTmpScontrol)
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
	else
		job_user="${ORANGY}${job_user}${NC}"
		job_name=""
	fi

	job_time=$(echo "$jobinfo" | grep -oP "RunTime=\K[0-9:]*")

	tmpString=$(echo "$jobinfo" | grep -o --color=never "Licenses=[WFB,0-9]*")
	if [[ "${#tmpString}" -gt 40 ]]; then
		job_licenses=$(echo "${tmpString::40}..." | grep --color=always "W[0-9]*")
	else
		job_licenses=$(echo "$tmpString" | grep --color=always "W[0-9]*")
	fi

	if echo "$job_status" | grep -q "RUNNING"; then
		jobsRunning="${jobsRunning}Job $job_id ($job_time) by $job_user has $job_licenses$job_name\n"
	else
		jobsPending="${jobsPending}Job $job_id by $job_user has $job_licenses$job_name\n"
	fi
 done
# redo previous change
unset IFS

echo -e "Running\n${jobsRunning}Pending\n${jobsPending}"
