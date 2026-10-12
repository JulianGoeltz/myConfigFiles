#!/bin/bash

if [ -n "${button}" ]; then
	google-chrome-stable https://calendar.google.com/ --password-store=basic &
	disown
fi

RED=$(printf '\033[1;31m')
ORANGY=$(printf '\033[0;33m')
SPECIAL=$(printf '\033[1;35m')
BOLD=$(printf '\033[1m')
NC=$(printf '\033[0m')

date +"%a %d %b %R"
