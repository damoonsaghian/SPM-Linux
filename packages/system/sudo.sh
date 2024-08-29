#!/usr/bin/env -S pkexec --keep-cwd /bin/bash
set -e
# if $PKEXEC_UID is not in sudo group, exit

# switch to virtual terminal 12 and ask for root password
# and if successful, run the given command
prompt_command="\\e[92m$(printf "%q " "$@")\\e[0m"
prompt="$prompt_command\nPWD: $PWD\nsudo password:"
if openvt -sw --console=12 -- /usr/local/bin/chkpasswd root "$prompt"; then
	"$@"
else
	echo "authentication failure"
fi
