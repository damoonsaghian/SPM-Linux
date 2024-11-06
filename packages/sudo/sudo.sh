#!/apps/sh
set -e

# if $DOAS_UID is not in sudo group, exit

if [ "$1" = addrule ]; then
	exit
fi
# https://unix.stackexchange.com/questions/364/allow-setuid-on-shell-scripts
# https://security.stackexchange.com/questions/194166/why-is-suid-disabled-for-shell-scripts-but-not-for-binaries
# https://www.drdobbs.com/dangers-of-suid-shell-scripts/199101190
# https://github.com/Lancia-Greggori/lanciautils/blob/main/C/priv.c
# https://salsa.debian.org/debian/super/
# "doas" allow password'less: /apps/bash /spm/installed/system/sudo.sh

# show this message:
# press F8 (or F7, F6, F5) to access the prompt asking for root password
#
# in virtual terminal 8, show the command at the top, and asks for sudo password
# when "enter" is pressed, returns back to previous virtual terminal
#
# if the entered password is correct, run the given command

prompt_command="\\e[92m$(printf "%q " "$@")\\e[0m"
prompt="$prompt_command\nPWD: $PWD\nsudo password:"
if openvt -sw --console=12 -- /usr/local/bin/chkpasswd root "$prompt"; then
	"$@"
else
	echo "authentication failure"
fi
