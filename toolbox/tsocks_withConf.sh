#!/bin/bash

TSOCKS_CONF_FILE=~/.config/tsocks.conf tsocks nc "$@"
