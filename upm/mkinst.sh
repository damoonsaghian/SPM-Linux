# creates a bootable installer on a removable storage device

script_dir="$(dirname "$(readlink -f "$0")")"

# name of the target device to write the installer on
# it's an optional argument
# if empty, this script will be interactive, and will allow the user to choose the target device
target_device="$1"

wdir="$HOME"/.cache/upm/mkinst
mkdir -p "$wdir"
cd "$wdir"

mkdir -p target
sh "$script_dir"/mkfs.sh fat "$wdir/target" "$target_device" || exit

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

. "$script_dir"/mkinst-alpine.sh; exit

trap "trap - EXIT; umount -q target; rmdir target" EXIT INT TERM QUIT HUP PIPE

# create  an initramfs (for $arch) that includes programs needed to install Uni
# https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage
mkdir initfs
# init, login as root, run install.sh

echo "bootable installer successfully created"
echo "now boot into the installation media, and follow the instructions"
