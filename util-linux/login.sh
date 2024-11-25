#!/exp/cmd/env sh

mkdir -p /run/user/1000
chmod 700 /run/user/1000

cd /home

# run services at /home/.spm/exp/sv, as the user 1000 (exas -n)

if [ "$(tty)" = "/dev/tty1" ]; then
	exas -n dbus-run-session sway || {
		spm install sway $gnunet_namespace/sway
		spm install swapps $gnunet_namespace/swapps
		spm install termulator $gnunet_namespace/termulator
		spm install codev $gnunet_namespace/codev
		exas -n  dbus-run-session sway || bash --norc || sh
	}
else
	bash -l || sh -l
fi
