#!/bin/bash

# set -euo pipefail

# get name with `xinput list`
name="SynPS/2 Synaptics TouchPad"
xinput list --long "$name" | grep "disabled"
if xinput list --long "$name" | grep -q "disabled"; then
	xinput enable "$name"
else
	xinput disable "$name"
fi
