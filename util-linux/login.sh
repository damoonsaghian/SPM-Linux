#!/exp/cmd/env sh

mkdir -p /run/user/1000
chmod 700 /run/user/1000

cd /home

export HOME="/home"
export PATH="$PATH:/$HOME/.local/bin"

# run services at /home/.spm/exp/sv, as the user 1000 (exas -n)

if [ "$(tty)" = "/dev/tty1" ]; then
	sudo -u1000 gsh || sudo -u1000 "bash --norc" || sudo -u1000 sh
else
	sudo -u1000 "bash --norc" || sudo -u1000 sh
fi
