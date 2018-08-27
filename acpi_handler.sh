#!/bin/sh

# is called from /etc/acpi/events/anything:
# # Pass all events to our one handler script
# event=.*
# action=/etc/acpi/handler.sh %e


# there are for arguments, echoing them like
# echo '$1:'$1',$2:'$2',$3:'$3',$4:'$4 >> /home/julgoe/tmp_acpi2.out
# writes: $1:button/lid,$2:LID,$3:close,$4:

case "$1" in 
	button*)
		case "$3" in
			close)
				grep -q closed /proc/acpi/button/lid/*/state
				if [ $? = 0 ]
				then
					date +%s > /home/julgoe/.tmp_lidclosingaction_tmstmp
					sudo pm-suspend
				        #	>> /home/julgoe/tmp_acpi.out
					exit
				fi
				;;
			open)
				tmp=$(cat /home/julgoe/.tmp_lidclosingaction_tmstmp)
				echo "open" > /home/julgoe/.tmp_lidclosingaction_tmstmp
				if [ ! $tmp = "open" ]; then
					if [ "$(($(date +%s)-$tmp))" -ge "$((60*60))" ]; then
						USER=$(ps -C i3 -o user=)
						if test $USER; then
						       	DISPLAY=:0.0 su $USER -c "xautolock -locknow"
							# if it isn't working check whether theres a xautolock running and try to lokc with -locknow in terminal
						fi
					fi
				fi
		esac
esac

