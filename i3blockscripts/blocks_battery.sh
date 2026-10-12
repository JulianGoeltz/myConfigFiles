source /home/$USER/myConfigFiles/i3blockscripts/blocks_defines.sh



case $1 in
	"state")
		echo "${emojiBattery}$(acpi --battery | cut -d, -f2)"
		;;
	"charging")
		acpi -b | grep -o " Charging" || true
		;;
	"discharging")
		acpi -b | grep -o " Discharging" || true
		;;
	"remain")
		tmp="$(acpi | cut -d, -f3 | head -c6 | tail -c5)"
		[ -n "${tmp}" ] && echo " (${tmp})"
		;;
esac
