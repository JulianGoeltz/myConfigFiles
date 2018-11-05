#!/bin/bash

if synclient | grep -q "TouchpadOff\s*=\s*0"; then
	synclient TouchpadOff=1
else
	synclient TouchpadOff=0
fi
