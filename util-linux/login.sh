#!/exp/cmd/env sh

prepare() {
	mkdir -p /run/user/1000
	chmod 700 /run/user/1000
	
	cd /home
	
	export HOME="/home"
	export PATH="$PATH:/$HOME/.local/bin"
	
	# run services at /home/.spm/exp/sv, as the user 1000 (sudo -u1000 ...)
}

# command'line shell
clsh() {
	# ask user for lockscreen password
	# check it (using sudo)
	# if correct:
	prepare
	sudo -u1000 "bash --norc" || sudo -u1000 sh
}

if [ "$(tty)" = "/dev/tty1" ]; then
	prepare
	sudo -u1000 gsh || clsh
else
	clsh
fi
