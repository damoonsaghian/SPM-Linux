script_dir="$(dirname "$(readlink -f "$0")")"

# if this script is run by any user other than root, just install "upm" to user's home directory, and exit
if [ $(id -u) != 0 ]; then
	state_dir="$XDG_STATE_HOME"
	[ -z "$state_dir" ] && state_dir="$HOME/.local/state"
	
	echo "UPM will try to download binary packages (instead of building from source), if they are available for your system"
	printf "do you want to always built packages from source? (y/N) "
	read -r ans
	if [ "$ans" = y ]; then
		mkdir -p "$state_dir"/upm
		echo "build'from'src" > "$state_dir"/upm/config
	fi
	
	sh "$script_dir/upm.sh" install "$(cat "$scripr_dir")"/../.meta/gns)" upm
	exit
fi

# format a storage device for installing the new system
new_root="$(mktemp -d)"
unmount_all="umount -q \"$new_root\"/boot; \
	umount -q \"$new_root\"/dev; umount -q \"$new_root\"/proc; \
	umount -q \"$new_root\"; rmdir \"$new_root\""
trap "trap - EXIT; $unmount_all" EXIT INT TERM QUIT HUP PIPE
sh "$script_dir"/format.sh sys "$new_root" || exit

. "$script_dir"/install-alpine.sh; exit

gnunet_namespace=

target_dir="$(mktemp -d)"
mount /dev/mapper/root "$target_dir"
trap "trap - EXIT; umount \"$target_dir\"; rmdir \"$target_dir\"" EXIT INT TERM QUIT HUP PIPE

mkdir -p "$target_dir"/{home,tmp,run,proc,sys,dev}
chown 1000:1000 "$target_dir"/home
chmod a+w "$target_dir"/tmp

echo "UPM will try to download binary packages (instead of building from source), if they are available for your system"
printf "do you want to always built packages from source? (y/N) "
read -r ans
if [ "$ans" = y ]; then
	mkdir -p "$target_dir"/var/lib/spm
	echo "build'from'src" > "$target_dir"/var/lib/spm/config
fi

export PATH="$target_dir/usr/bin:$PATH"

echo 'acpid
bluez
chrony
cryptsetup
dbus
dinit
doas
dte
eudev
gnunet
linux
netman
pipewire
sbase
sh
tpm2-tools
uni
upm
ushare
ushell
util-linux' | while read -r pkg_name; do
	ROOT_DIR="$target_dir" sh "$script_dir"/spm.sh install "$(cat "$scripr_dir")"/../.meta/gns)" "$pkg_name"
done

# set root password

# useradd --create-home --home-dir /nu --shell /usr/bin/ushell

echo; echo -n "SPM Linux installed successfully; press any key to exit"
read -rsn1
