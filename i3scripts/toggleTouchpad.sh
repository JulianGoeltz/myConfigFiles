#!/bin/bash

# set -euo pipefail

# get name with `xinput list`
name="SYNA8018:00 06CB:CE67 Touchpad"
if xinput list --long "$name" | grep -q "disabled"; then
	xinput enable "$name"
else
	xinput disable "$name"
fi
