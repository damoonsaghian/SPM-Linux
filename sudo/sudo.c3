// https://git.suckless.org/ubase/file/passwd.c.html
// https://git.busybox.net/busybox/tree/loginutils/cryptpw.c
// https://github.com/mirror/busybox/blob/master/loginutils/cryptpw.c

// clear all the environment variables

// if "--term <term>" is given: export TERM=<term>

// -u<uid>: user with id <uid>

// export SUDO=1

/*
if requested to run the given command as user 1000
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
if command and its arguments are in /var/state/sudo/allow, run it, otherwise:

show this message:
press F8 (or F7, F6, F5) to access the prompt asking for root password

in virtual terminal 2, run sway as system user 10, with a config file that only runs a dialog
the dialog shows the command at the top, and asks for sudo password
when "enter" is pressed, closes all, and returns back to previous virtual terminal
if you are in console (instead of graphical env), do the above in console as root (instead of in sway as system user 10)

if the entered password is correct, run the given command

prompt_command="\\e[92m$(printf "%q " "$@")\\e[0m"
prompt="$prompt_command\nPWD: $PWD\nsudo password:"
if openvt -sw --console=12 -- /usr/local/bin/chkpasswd root "$prompt"; then
	"$@"
else
	echo "authentication failure"
fi
*/

/*
sudo passwd root
sudo passwd

if argv[0] begin with "/", find the realpath of argv[0], then the dirname, then ../../../var/lib/sudo/passwd
otherwise just use /var/lib/sudo/passwd

echo; printf "set root password: "
while true; do
	read -rs root_password
	printf "enter password again: "
	read -rs root_password_again
	[ "$root_password" = "$root_password_again" ] && break
	echo "the entered passwords were not the same; try again"
	printf "set root password: "
done
root_password_hashed="$($root_password)"
mkdir -p "$spm_linux_dir"/var/state/sudo/passwd
echo "$root_password_hashed" > "$spm_linux_dir"/var/state/sudo/passwd

echo; printf "set lock'screen password: "
while true; do
	read -rs lock_password
	printf "enter password again: "
	read -rs lock_password_again
	[ "$lock_password" = "$lock_password_again" ] && break
	echo "the entered passwords were not the same; try again"
	printf "set lock'screen password: "
done
lock_password_hashed=
echo "$lock_password_hashed" >> "$spm_linux_dir"/var/state/sudo/passwd
*/
