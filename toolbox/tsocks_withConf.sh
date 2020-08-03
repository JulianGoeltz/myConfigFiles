#!/bin/bash

TSOCKS_CONF_FILE=~/myConfigFiles/tsocks.conf tsocks nc "$@"
