# primary interface
# the ancestor of all user interface processes
# login, then wait for dbus messages:
# , run command as root (with or without password)
# , verify user password

# login:
# , mkdir -p /run/user/1000
# , chmod 700 /run/user/1000
# , clears all the environment variables except TERM
# , initializes the environment variables HOME, SHELL, USER, LOGNAME, and PATH
# , changes to the target user’s home directory
# , sets argv[0] of the shell to '-' in order to make the shell a login shell
# , export XDG_RUNTIME_DIR=/run/user/1000
# , run services at ~/.local/spm/sv, as the user 1000
# , add /apps to PATH
# , run "sway" and if it fails:
# 	spm install sway $gnunet_namespace/sway
# 	spm install swapps $gnunet_namespace/swapps
# 	spm install termulator $gnunet_namespace/termulator
# 	spm install codev $gnunet_namespace/codev
#
# echo '#!/apps/env sh
# [ "$(tty)" = "/dev/tty1" ] && dbus-run-session sway || bash || sh
# ' > "$project_dir"/.cache/spm/apps/sv/bash

verify_passwd() {
	username="$1"
	prompt="$2"
	passwd_hashed="$(cat /var/lib/uzero/passwd | head -n2)"
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

# if command and its arguments are in /var/lib/pi/permit, run it, otherwise:
#
# show this message:
# press F8 (or F7, F6, F5) to access the prompt asking for root password
#
# in virtual terminal 8, show the command at the top, and asks for sudo password
# when "enter" is pressed, returns back to previous virtual terminal
#
# if the entered password is correct, run the given command
#
# prompt_command="\\e[92m$(printf "%q " "$@")\\e[0m"
# prompt="$prompt_command\nPWD: $PWD\nsudo password:"
# if openvt -sw --console=12 -- /usr/local/bin/chkpasswd root "$prompt"; then
# 	"$@"
# else
# 	echo "authentication failure"
# fi

# verify_passwd user
