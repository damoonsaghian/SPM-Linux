# create a bootable installer on a removable storage device

script_dir="$(dirname "$(readlink -f "$0")")"

# name of the target device to write the installer on
# it's an optional argument
# if empty, this script will be interactive, and will allow the user to choose the target device
target_device="$1"

printf 'installation media can be made for these architectures:
	1) x86_64
	2) aarch64
	3) riscv64
'
echo "enter the number of the desired architechture: "
read -r ans
case "$ans" in
1) arch=x86_64 ;;
2) arch=aarch64 ;;
3) arch=riscv64 ;;
esac

wdir="$(mktemp -d)"
cd "$wdir"
mkdir target
trap "trap - EXIT; umount -q \"$wdir\"target && rm -r \"$wdir\"" EXIT INT TERM QUIT HUP PIPE

# download sd.sh from Codev/codev-shell (using gnunet or curl)

sh sd.sh format-inst target "$target_device" || exit

# create  an initramfs (for $arch) that includes programs needed to install SPM Linux, plus the content of this project
# https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage
mkdir initfs
# init, login as root, run new.sh

echo "bootable installer successfully created"
