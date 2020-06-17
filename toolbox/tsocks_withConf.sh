#!/bin/bash

TSOCKS_CONF_FILE=/wang/users/jgoeltz/cluster_home/myConfigFiles/tsocks.conf tsocks nc "$@"
