#!/bin/bash

# set -euo pipefail

RED='\033[1;31m'
ORANGY='\033[0;33m'
SPECIAL='\033[1;35m'
NC='\033[0m'

JENKINSSPECIALSETUP=W62F

fileTmpScontrol=~/.tmp_scontrol2.sh

jobsRunning=""
jobsPending=""

if [ $# -gt 0 ]; then
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		cat <<EOF
Listing licences currently either pending or running.

* first listed are runnning, then pending, and in colorful output
* only the cube setups are looked at
* if arguments are given (other than -h or --help), they are used as arguments
  for grep on the jobinfo, and in case they fit the job is skipped. This is 
  useful to still see important info if someone is spamming the queue
* jobs on environment variable {LLSS} (ListLicencesSpecialSetup, for setups
  that are of special interest) are highlighted; can be regex. Example:
  \$LLSS=W66 or \$LLSS="(W66|W67)"
* vis_jenkin on setup ${JENKINSSPECIALSETUP} is shortened to reduce clutter
* if job_user and USER agree, special magic is done to infer info about the job
EOF
		exit
	else
		echo "skipping '$@'"
	fi
fi

IFS=$'\n'
# for job in $(squeue -p "experiment" --sort=-t,u --noheader -o "%i %u %M %T" "$@"); do
for jobinfo in $(scontrol show -o job); do
	echo "$jobinfo" | grep -vqP "Partition=(cube)" && continue
	if echo "$jobinfo" | grep -q vis_jenkin && echo "$jobinfo" | grep -q $JENKINSSPECIALSETUP; then
		vis_jenkin="on $JENKINSSPECIALSETUP"
		continue
	fi
	job_id=$(echo "$jobinfo" | grep -oP "JobId=\K[0-9]*")

	# if arguments given they are passed onto grep of the jobinfo
	if [ $# -gt 0 ]; then
		echo "$jobinfo" | grep -q "$@" && continue
	fi

	job_status=$(echo "$jobinfo" | grep -oP "JobState=\K\S*")
	# only include running/pending jobs
	echo "$job_status" | grep -vqP "RUNNING|PENDING" && continue
	job_status=$(printf '%7s' "$job_status")

	job_host=" on $(echo "$jobinfo" | grep -oP "BatchHost=\K[^ ]*")"
	echo "$job_status" | grep -vqP "RUNNING" && job_host=""

	job_user=$(echo "$jobinfo" | grep -oP "UserId=\K[^\(]*")
	job_user=$(printf '%10s' "$job_user")
	job_user=${job_user:0:10}
	if echo "$job_user" | grep -q "$USER" ; then
		job_user="${RED}${job_user}${NC}"

		if echo "$jobinfo" | grep -q "JobName=wrap" ; then
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
		elif echo "$jobinfo" | grep -q "JobName=hx_" ; then
			if [[ "$job_status" == "RUNNING" ]]; then
				tmpOutputFile=$(echo "$jobinfo" | grep -oP "StdOut=\K\S*")
				tmpState=$(grep -P "... [0-9.]*% done" "$tmpOutputFile" | tail -n 1 | grep -oP "[0-9.]*")
				job_name=", $(echo "$tmpState" | head -n2 | tail -n1)%: train $(echo "$tmpState" | head -n3 | tail -n1), valid $(echo "$tmpState" | head -n4 | tail -n1)"
			else
				job_name=", $(echo "$jobinfo" | grep -oP "JobName=\K\S*")"
			fi
		else
			job_name=", "
		fi
	else
		job_user="${ORANGY}${job_user}${NC}"
		job_name=""
	fi

	job_time=$(echo "$jobinfo" | grep -oP "RunTime=\K[0-9:-]*")

	# cut off too long licences
	tmpString=$(echo "$jobinfo" | grep -o --color=never "Licenses=[WFB,0-9]*")
	if [[ "${#tmpString}" -gt 40 ]]; then
		job_licenses="${tmpString::40}..."
	else
		job_licenses="$tmpString"
	fi
	if [ -n "$LLSS" ] && echo "$job_licenses" | grep -qP "$LLSS"; then
		# job_licenses="Licenses=$(tput bold)${SPECIAL}$(echo "$job_licenses" | grep "[WFB,0-9]")$(tput sgr0)${NC}"
		job_licenses="Licenses=${SPECIAL}$(echo "$job_licenses" | grep -o "[WFB,0-9]*")${NC}"
	else
		job_licenses=$(echo "$job_licenses" | grep --color=always "W[0-9]*")
	fi

	if echo "$job_status" | grep -q "RUNNING"; then
		jobsRunning="${jobsRunning}Job $job_id ($job_time) by $job_user has $job_licenses$job_host$job_name\n"
	else
		jobsPending="${jobsPending}Job $job_id by $job_user has $job_licenses$job_host$job_name\n"
	fi
 done
# redo previous change
unset IFS

[ -n "${vis_jenkin}" ] && echo -e "(${ORANGY}vis_jenkin${NC} ${vis_jenkin})"
echo -en "Running\n${jobsRunning}"
echo -e "Pending\n${jobsPending}"
