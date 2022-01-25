#!/bin/bash

# set -euo pipefail

RED=$(printf '\033[1;31m')
ORANGY=$(printf '\033[0;33m')
SPECIAL=$(printf '\033[1;35m')
NC=$(printf '\033[0m')

JENKINSSPECIALSETUP=W62F

fileTmpScontrol=~/.tmp_scontrol2.sh

jobsRunning=""
jobsPending=""

help_text() {
	cat <<EOF
Listing licences currently either pending or running.

* first listed are runnning, then pending, and in colorful output
* only the cube setups are looked at
* vis_jenkin on setup ${JENKINSSPECIALSETUP} is shortened to reduce clutter
* if job_user and USER agree, special magic is done to infer info about the job
* arguments:
   [-h|--help] this help text
   [-s|--skip <pattern>] pattern used as arguments for grep on the jobinfo to
        skip the job on match. This is useful to still see important info if
	someone is spamming the queue
   [-c|--color|--colour <pattern>] identifier for setups of interest to be
        highlighted can be regex. Example: '-c W66' or pattern '-c "(W66|W67)"'
EOF
}

# parse potential arguments
if [ $# -gt 0 ]; then
	case $1 in
		"-s"|"--skip")
			patternForSkipping=$2
			shift 2
			;;
		"-c"|"--color"|"--colour")
			LLSS=$2
			shift 2
			;;
		"-h"|"--help"|*)
			help_text
			exit
			;;
	esac
fi

IFS=$'\n'
# for job in $(squeue -p "experiment" --sort=-t,u --noheader -o "%i %u %M %T" "$@"); do
for jobinfo in $(scontrol show -o job --all); do
	echo "$jobinfo" | grep -vqP "Partition=(cube|jenkins)|UserId=$USER" && continue
	if echo "$jobinfo" | grep -q vis_jenkin; then
		if echo "$jobinfo" | grep -q "Licenses=$JENKINSSPECIALSETUP"; then
			vis_jenkin="on $JENKINSSPECIALSETUP"
			continue
		elif echo "$jobinfo" | grep -q "Licenses=(null)"; then
			continue
		fi
	fi
	job_id=$(echo "$jobinfo" | grep -oP "JobId=\K[0-9]*")

	# if arguments given they are passed onto grep of the jobinfo
	if [ -n "$patternForSkipping" ]; then
		echo "$jobinfo" | grep -q "$patternForSkipping" && continue
	fi

	job_status=$(echo "$jobinfo" | grep -oP "JobState=\K\S*")
	# only include running/pending jobs
	echo "$job_status" | grep -vqP "RUNNING|PENDING" && continue
	job_status=$(printf '%7s' "$job_status")

	if echo "$job_status" | grep -qP "RUNNING"; then
		job_host="$(echo "$jobinfo" | grep -oP "BatchHost=\K[^ ]*")"
		job_host=" on $(printf '%10s' "$job_host")"
	else
		job_host=""
	fi

	job_user=$(echo "$jobinfo" | grep -oP "UserId=\K[^\(]*")
	job_user=$(printf '%10s' "$job_user")
	job_user=${job_user:0:10}
	if echo "$job_user" | grep -qP "$USER" ; then
		job_user="${RED}${job_user}${NC}"

		if echo "$jobinfo" | grep -q "JobName=wrap" ; then
			scontrol write batch_script "$job_id" $fileTmpScontrol >/dev/null
			job_name=$([ -f $fileTmpScontrol ] && grep -oP "\S*(\.yaml|\.hdf5|experiment_results)\S*" $fileTmpScontrol)
			if [ -n "$job_name" ]; then
				if [[ "$(echo "$job_name" | wc -l)" -eq 1 ]]; then
					if echo "$job_name" | grep -q yaml; then
						job_name=", $(basename "$(dirname "$job_name")")/$(basename "$job_name")"
					else
						job_name=", $(basename "$job_name")"
					fi
					if [[ "$job_status" == "RUNNING" ]]; then
						tmpOutputFile=$(echo "$jobinfo" | grep -oP "StdOut=\K\S*")
						if grep -qP "... [0-9.]*% done" "$tmpOutputFile"; then
							tmpState=$(grep -P "... [0-9.]*% done" "$tmpOutputFile" | tail -n 1 | grep -oP "[0-9.]*")
							job_name="$job_name, $(echo "$tmpState" | head -n2 | tail -n1)%: train $(echo "$tmpState" | head -n3 | tail -n1), valid $(echo "$tmpState" | head -n4 | tail -n1)"
						fi
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
			job_name=""
		fi
	elif echo "$job_user" | grep -qP "vis_jenkin"; then
		if echo "$jobinfo" | grep -q "JobName=p_jg_FastAndDeep"; then
			job_name=", ${SPECIAL}$(echo "$jobinfo" | grep -oP "JobName=\K[^ ]*")${NC}"
		elif echo "$jobinfo" | grep -q "JobName=hourly_hx_health_check"; then
			continue
		else
			job_name=""
			# job_name=", ${SPECIAL}$(echo "$jobinfo" | grep -oP "JobName=\K[^ ]*")${NC}"
		fi
		job_user="${ORANGY}${job_user}${NC}"
	else
		job_user="${ORANGY}${job_user}${NC}"
		job_name=""
	fi

	job_time=$(echo "$jobinfo" | grep -oP "RunTime=\K[0-9:-]*")
	job_time=$(printf '%10s' "$job_time")

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
if [ -n "$LLSS" ]; then
	freesetups="$(find_free_chip.py | sed -r "s#$LLSS#${SPECIAL}&${NC}#" | tr '\n' ' ')"
else
	freesetups="$(find_free_chip.py | tr '\n' ' ')"
fi
echo -e "Free setups: ${freesetups}"
