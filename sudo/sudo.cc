/*
sudo in SPMlinux does not suffer from these:
https://www.reddit.com/r/linuxquestions/comments/8mlil7/whats_the_point_of_the_sudo_password_prompt_if/
https://security.stackexchange.com/questions/119410/why-should-one-use-sudo
because:
, when a user enters "sudo" in command line, it will run /usr/bin/sudo without any manipulation
, reaching to terminal in swapp can't be manipulated
	swapp -> system -> sudo <command>
, swapp only allows keyboard input from real keyboard, or from the on'screen one
, there is no way to replace swapp; when swapp terminates, the session will logout
	just like when we are in a virtual terminal
this means that:
, a malicious program can't steal root password (eg by faking root password entry)
, to run a command as root, physical access is necessary, because there is no other way to enter root password
*/

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

// create and verify hashed password
// https://git.suckless.org/ubase/file/passwd.c.html
// https://git.busybox.net/busybox/tree/loginutils/cryptpw.c
// https://github.com/mirror/busybox/blob/master/loginutils/cryptpw.c
// https://github.com/rfc1036/whois/blob/next/mkpasswd.c

// if command and its arguments are in /var/state/sudo/allow, run it
// otherwise, verify password, and if it's correct, run the command, otherwise: echo "authentication failure"

/*
sudo passwd root
sudo passwd

if argv[0] begin with "/", find the realpath of argv[0], then the dirname, then ../../../var/lib/sudo/passwd
otherwise just use /var/lib/sudo/passwd

printf "set root password: "
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

printf "set lock'screen password: "
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
