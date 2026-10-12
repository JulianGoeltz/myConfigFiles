#!/bin/bash

# needs the customBrowser.desktop installed
# sudo desktop-file-install customBrowser.desktop
# (should be in /usr/share/applications/customBrowser.desktop)
# (and maybe set with as default, as described in there ^)
#
# and in "$HOME/.config/mimeapps.list"
# other_configs/mimeapps.list

echo "${1}" | xclip -i -selection clipboard
notify-send "copied to clipboard" "${1}"
if [[ "${1}" =~ 'https://eur03.safelinks.protection.outlook.com/' ]]; then
	/home/$USER/myConfigFiles/toolbox/cleanLink.sh
fi
