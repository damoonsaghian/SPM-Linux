// clear all the environment variables

// if "--term <term>" is given: export TERM=<term>

export SUDO=1

/*
if the received dbus message, request to run the given command as user 1000
initialize the environment variables:
	HOME=/home, SHELL=/apps/bash, USER=user, LOGNAME=user, and PATH=/home/.spm/exp/cmd:/exp/cmd
XDG_STATE_HOME=/home/.spm/var/state
XDG_CONFIG_HOME=/home/.spm/var/state
XDG_CACHE_HOME=/home/.spm/var/cache
XDG_RUNTIME_DIR=/run/user/1000
*/

/*
verify_passwd() {
	username="$1"
	prompt="$2"
	passwd_hashed="$(cat /var/state/run/passwd | head -n2)"
	salt = "$(echo "$passwd_hashed" | grep -o '.*\$')";
	println("%s ", prompt)
	entered_passwd= #read a line as password
	printf
	entered_passwd_hashed="$(MKPASSWD_OPTIONS="-S $salt" mkpasswd -s <<< "$entered_passwd")"
	if [ entered_passwd_hashed = passwd_hashed ]; then
		exit
	else
		exit 1
	fi
}
*/

/*
if command and its arguments are in /var/state/sudo, run it, otherwise:

show this message:
press F8 (or F7, F6, F5) to access the prompt asking for root password

in virtual terminal 8, show the command at the top, and asks for sudo password
when "enter" is pressed, returns back to previous virtual terminal

if the entered password is correct, run the given command

prompt_command="\\e[92m$(printf "%q " "$@")\\e[0m"
prompt="$prompt_command\nPWD: $PWD\nsudo password:"
if openvt -sw --console=12 -- /usr/local/bin/chkpasswd root "$prompt"; then
	"$@"
else
	echo "authentication failure"
fi
*/
