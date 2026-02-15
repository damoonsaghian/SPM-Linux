mkdir -p iso_mount
ovl_dir="$(mktemp -d)"
trap "trap - EXIT; umount -q target; umount -q iso_mount; rmdir target iso_mount; rm -r \"$ovl_dir\"" \
	EXIT INT TERM QUIT HUP PIPE

mkdir -p "$ovl_dir"/uinst
cp -r "$script_dir"/../uni "$ovl_dir"/uinst/
cp -r "$script_dir"/../upkgs "$ovl_dir"/uinst/
cp -r "$script_dir"/../upm "$ovl_dir"/uinst/
cp -r "$script_dir"/../ushell "$ovl_dir"/uinst/
mkdir -p "$ovl_dir"/uinst/uni/data
cp "$script_dir"/../.data/uni.svg "$ovl_dir"/uinst/uni/data/ 2>/dev/null ||
	cp /usr/share/icons/hicolor/scalable/apps/uni.svg "$ovl_dir"/uinst/uni/data/

mkdir -p "$ovl_dir"/root
printf 'sh /uinst/upm/install.sh
' > "$ovl_dir"/root/.profile

printf '#!/usr/bin/env sh
exec login -f root
' > "$ovl_dir"/uinst/autologin
chmod +x "$ovl_dir"/uinst/autologin

mkdir -p "$ovl_dir"/etc
printf '::sysinit:/sbin/openrc sysinit
::sysinit:/sbin/openrc boot
::wait:/sbin/openrc default
tty1::respawn:/sbin/getty -n -l /uinst/autologin 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/openrc shutdown
' > "$ovl_dir"/etc/inittab

# this is necessary when using an overlay
touch "$ovl_dir"/etc/.default_boot_services

rm -f localhost.apkovl.tar.gz
tar --owner=0 --group=0 -czf target/localhost.apkovl.tar.gz "$ovl_dir"

# try previously downloaded file from cache, and exit if there is none
try_cached_alpine_iso() {
	alpine_iso_file_name=$(ls alpine-standard-*-"$arch".iso | tail -n1)
	sha256sum "$alpine_iso_file_name" || exit
	if [ -e "$alpine_iso_file_name" ]; then
		echo "using previousely downloaded file: '$wdir/$alpine_iso_file_name'"
	else
		echo "alternatively, download the standard image from \"https://alpinelinux.org/downloads/\","
		echo "	and put it in \"$wdir\""
		exit 1
	fi
}

download_url="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$arch"
if command -v curl; then
	if curl --proto '=https' -fO "$download_url/latest-releases.yaml"; then
		alpine_iso_file_name="$(cat latest-releases.yaml | grep "file: alpine-standared-.*")"
		alpine_iso_file_name="$(echo "$alpine_iso_file_name" | cut -d: -f2 | tr -d "[:blank:]")"
		curl --proto '=https' -fO -C- "$download_url/$alpine_iso_file_name"
		curl --proto '=https' -fO  "$download_url/$alpine_iso_file_name.sha256"
		sha256sum "$alpine_iso_file_name" || {
			rm -f "$alpine_iso_file_name"
			echo "downloaded file was corrupted; try again"
			exit 1
		}
	else
		echo "can't reach Alpine Linux server; try again"
		try_cached_alpine_iso
	fi
elif command -v wget; then
	rm -f latest-releases.yaml
	if wget --no-verbose "$download_url/latest-releases.yaml"; then
		alpine_iso_file_name="$(cat latest-releases.yaml | grep "file: alpine-standared-.*")"
		alpine_iso_file_name="$(echo "$alpine_iso_file_name" | cut -d: -f2 | tr -d "[:blank:]")"
		wget --no-verbose --show-progress --no-clobber "$download_url/$alpine_iso_file_name"
		rm -f "$alpine_iso_file_name.sha256"
		wget --no-verbose "$download_url/$alpine_iso_file_name.sha256"
		sha256sum "$alpine_iso_file_name" || {
			rm -f "$alpine_iso_file_name"
			echo "downloaded file was corrupted; try again"
			exit 1
		}
	else
		echo "can't reach Alpine Linux server; try again"
		try_cached_alpine_iso
	fi
else
	echo "can't download Alpine Linux installer image"
	echo "either \"curl\" nor \"wget\" is required"
	try_cached_alpine_iso
fi

mount "$alpine_iso_file_name" iso_mount
cp -r iso_mount/* target/

echo "bootable Uni installer successfully created"
echo "now boot into the installation media, and follow the instructions"
