script_dir="$(dirname "$(readlink -f "$0")")"

. "$script_dir"/install-alpine.sh; exit

gnunet_namespace="$(cat "$(dirname "$(readlink -f "$0")")"/../.meta/gns)"

# if this script is run by any user other than root, just install "spm" to user's home directory, and exit
if [ $(id -u) != 0 ]; then
	state_dir="$XDG_STATE_HOME"
	[ -z "$state_dir" ] && state_dir="$HOME/.local/state"
	
	echo "UPM will try to download binary packages (instead of building from source), if they are available for your system"
	printf "do you want to always built packages from source? (y/N) "
	read -r ans
	if [ "$ans" = y ]; then
		mkdir -p "$state_dir"/spm
		echo "build'from'src" > "$state_dir"/spm/config
	fi
	
	spm_dir="$state_dir/spm/builds/$gnunet_namespace/spm"
	mkdir -p "$spm_dir"
	cp "$(dirname "$0")/spm.sh" "$spm_dir/"
	sh "$spm_dir"/spm.sh install "$gnunet_namespace" spm
	exit
fi

ARCH="$(uname --machine)"
# list available cpu architectures, and let the user choose
# riscv64, aarch64, x86_64
# current system's cpu architecture is the default (on empty input)
ARCH=
export ARCH

target_dir="$(mktemp -d)"
mount /dev/mapper/root "$target_dir"
trap "trap - EXIT; umount \"$target_dir\"; rmdir \"$target_dir\"" EXIT INT TERM QUIT HUP PIPE

mkdir -p "$target_dir"/{home,tmp,run,proc,sys,dev}
chown 1000:1000 "$target_dir"/home
chmod a+w "$target_dir"/tmp

# bootstraping and cross compilation
# https://www.linuxfromscratch.org/lfs/view/stable/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html
# https://github.com/glasnostlinux/glasnost
# https://github.com/iglunix
# https://github.com/oasislinux/oasis
# https://mcilloni.ovh/2021/02/09/cxx-cross-clang/

echo "UPM will try to download binary packages (instead of building from source), if they are available for your system"
printf "do you want to always built packages from source? (y/N) "
read -r ans
if [ "$ans" = y ]; then
	mkdir -p "$target_dir"/var/lib/spm
	echo "build'from'src" > "$target_dir"/var/lib/spm/config
fi

upm_dir="$target_dir/var/lib/spm/builds/$gnunet_namespace/upm"
mkdir -p "$upm_dir"
cp "$(dirname "$0")"/spm.sh "$upm_dir"/

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
upm
tpm2-tools
util-linux
codev-shell
codev' | while read -r pkg_name; do
	sh "$upm_dir"/spm.sh install "$gnunet_namespace" "$pkg_name"
done

# set sudo password
"$target_dir"/usr/bin/sudo --passwd --root "$target_dir"

# useradd --create-home --home-dir /nu --shell /usr/bin/codev-shell

echo; echo -n "SPM Linux installed successfully; press any key to exit"
read -rsn1
