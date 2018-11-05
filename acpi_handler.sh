#!/bin/sh

# is called from /etc/acpi/events/anything:
# # Pass all events to our one handler script
# event=.*
# action=/etc/acpi/handler.sh %e


# there are for arguments, echoing them like
# echo '$1:'$1',$2:'$2',$3:'$3',$4:'$4 >> /home/julgoe/tmp_acpi2.out
# writes: $1:button/lid,$2:LID,$3:close,$4:

#this is the old way, now due to docking done with /etc/systemd/logind.conf and LidAction or sth, and /etc/pm/sleep.d/lock
# case "$1" in 
# 	button*)
# 		case "$3" in
# 			close)
# 				grep -q closed /proc/acpi/button/lid/*/state
# 				if [ $? = 0 ]
# 				then
# 					DockStatus=$(cat /sys/devices/platform/dock.0/docked)
# 					if [ "$DockStatus" = "0" ]; then
# 						date +%s > /home/julgoe/.tmp_lidclosingaction_tmstmp
# 						sudo pm-suspend
# 						#	>> /home/julgoe/tmp_acpi.out
# 						exit
# 					fi
# 				fi
# 				;;
# 			open)
# 				tmp=$(cat /home/julgoe/.tmp_lidclosingaction_tmstmp)
# 				echo "open" > /home/julgoe/.tmp_lidclosingaction_tmstmp
# 				if [ ! $tmp = "open" ]; then
# 					if [ "$(($(date +%s)-$tmp))" -ge "$((60*60))" ]; then
# 						USER=$(ps -C i3 -o user=)
# 						if test $USER; then
# 						       	DISPLAY=:0.0 su $USER -c "xautolock -locknow"
# 							# if it isn't working check whether theres a xautolock running and try to lokc with -locknow in terminal
# 						fi
# 					fi
# 				fi
# 		esac
# esac

