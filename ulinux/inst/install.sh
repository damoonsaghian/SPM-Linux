echo "not yet implemented"; exit

gnunet_namespace="$(cat "$(dirname "$(readlink -f "$0")")"/../.meta/gns)"

ARCH="$(uname --machine)"
# list available cpu architectures, and let the user choose
# riscv64, aarch64, x86_64
# current system's cpu architecture is the default (on empty input)
ARCH=
export ARCH

spm_linux_dir="$(mktemp -d)"
mount /dev/mapper/root "$spm_linux_dir"
trap "trap - EXIT; umount \"$spm_linux_dir\"; rmdir \"$spm_linux_dir\"" EXIT INT TERM QUIT HUP PIPE

mkdir -p "$spm_linux_dir"/{home,tmp,run,proc,sys,dev}
chown 1000:1000 "$spm_linux_dir"/home
chmod a+w "$spm_linux_dir"/tmp

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
	mkdir -p "$spm_linux_dir"/var/lib/spm
	echo "build'from'src" > "$spm_linux_dir"/var/lib/spm/config
fi

spm_dir="$spm_linux_dir/var/lib/spm/builds/$gnunet_namespace/spm"
mkdir -p "$spm_dir"
cp "$(dirname "$0")"/spm.sh "$spm_dir"/

export PATH="$spm_linux_dir/usr/bin:$PATH"

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
spm
tpm2-tools
util-linux
codev-shell
codev' | while read -r pkg_name; do
	sh "$spm_dir"/spm.sh install "$gnunet_namespace" "$pkg_name"
done

# set sudo password
"$spm_linux_dir"/usr/bin/sudo --passwd --root "$spm_linux_dir"

# useradd --create-home --home-dir /nu --shell /usr/bin/codev-shell

echo; echo -n "SPM Linux installed successfully; press any key to exit"
read -rsn1
