#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh

echo "$emojiFan $(sensors -j thinkpad-isa-0000 2>/dev/null | jq '."thinkpad-isa-0000"."fan1"."fan1_input"' | grep -oP "[0-9]*(?=\.)" )"
