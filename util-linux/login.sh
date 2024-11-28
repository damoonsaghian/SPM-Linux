#!/exp/cmd/env sh

mkdir -p /run/user/1000
chmod 700 /run/user/1000

cd /home

# run services at /home/.spm/exp/sv, as the user 1000 (exas -n)

if [ "$(tty)" = "/dev/tty1" ]; then
	sudo -n gsh || sudo -n "bash --norc" || sudo -n sh
else
	bash -l || sh -l
fi
