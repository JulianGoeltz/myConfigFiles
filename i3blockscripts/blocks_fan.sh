#!/bin/bash

# set -euo pipefail
source /home/$USER/myConfigFiles/i3blockscripts/blocks_defines.sh

# emoji
echo -n "$emojiFan "
# temperature
echo -n "$(cat /proc/acpi/ibm/thermal | cut -f2 | tr ' ' '\n' | sort -n | tail -n1)° "
# fan level
echo -n "$(cat /proc/acpi/ibm/fan | head -n3 | tail -n1 | cut -f3) "
# fan speed
echo -n "$(sensors -j thinkpad-isa-0000 2>/dev/null | jq '."thinkpad-isa-0000"."fan1"."fan1_input"' | grep -oP "[0-9]*(?=\.)")"
echo
