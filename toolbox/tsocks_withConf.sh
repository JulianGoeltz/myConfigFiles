#!/bin/bash

TSOCKS_CONF_FILE=~/myConfigFiles/other_configs/tsocks.conf tsocks nc "$@"
