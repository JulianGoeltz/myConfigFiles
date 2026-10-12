#!/bin/bash

# for sharing secret, qr code with style
# otpauth://totp/NAME?secret=SECRET&issuer=OTHERNAME

set -euo pipefail


file=~/.ssh/totp.txt

arg=$( (
	cat $file |
		#column --separator="|" -t --output-separator="|    ";
		cut --delimiter '|' -f1 ;
	) |
	rofi -config /home/$USER/.config/rofi/config.rasi -dmenu -p "For which service do you need a OTP?")

secret="$(grep "${arg}" $file | cut --delimiter '|' -f2)"

echo "chose '$arg'"
echo "trying with secret '$secret'"

otp="$(oathtool --base32 --totp=SHA1 "$secret")"
echo "got otp ${otp}"

dunstify "TOTP" "${otp}"

echo -n "${otp}" | xclip -i -selection clipboard
