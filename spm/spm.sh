#!/exp/env sh
set -e

[ -z "$ARCH" ] && ARCH="$(uname --machine)"

script_dir="$(dirname "$(realpath "$0")")"

root_dir="$script_dir/../../.."
if [ "$(id -u)" = 0 ]; then
	packages_dir="$root_dir/packages"
	cmd_dir="$root_dir/exp/cmd" # "exp" directory contains package exports
	sv_dir="$root_dir/exp/sv"
	dbus_dir="$root_dir/exp/dbus"
	apps_dir="$root_dir/exp/apps"
	state_dir="$root_dir/var/lib"
	cache_dir="$root_dir/var/cache"
else
	packages_dir="$HOME/.packages"
	cmd_dir="$HOME/.local/bin"
	
	data_dir="$XDG_DATA_HOME"
	[ -z "$data_dir" ] && data_dir="$HOME/.local/share"
	dbus_dir="$data_dir/dbus-1"
	apps_dir="$data_dir/applications"
	
	state_dir="$XDG_STATE_HOME"
	[ -z "$state_dir" ] && state_dir="$HOME/.local/state"
	cache_dir="$XDG_CACHE_HOME"
	[ -z "$cache_dir" ] && cache_dir="$HOME/.cache"
fi

mkdir -p "$packages_dir" "$cmd_dir" "$sv_dir" "$dbus_dir" "$apps_dir" "$state_dir" "$cache_dir"

make_commands() {
	for executable in "$@"; do
		# executable script in .cache/spm/exp/cmd:
		# LD_LIBRARY_PATH=".:./deps"
		# PATH=".:./deps:$PATH"
	done
}

make_apps() {
	for executable in "$@"; do
	done
}

git_clone_tag() {
	# https://man.archlinux.org/listing/git
	
	# https://git-scm.com/docs/partial-clone
	
	# lsh-keygen/ssh-keygen to verify git tags
	# https://git-scm.com/docs/git-verify-tag
	# https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgltformatgtprogram
	# https://manpages.debian.org/bookworm/lsh-utils/lsh-keygen.1.en.html
	# https://manpages.debian.org/bookworm/openssh-client/ssh-keygen.1.en.html
	
	# if a gpg key is given, download and/or build gpg package
}

spm_build() {
	local pkg_name=
	local pkg_dir="$1"
	case "$1" in
	gnunet://*)
		build_dir="$cache_dir/spm/builds/$gn_namespace/$pkg_name"
	*)
		build_dir="$cache_dir/spm/builds/$pkg_group/$pkg_name"
		;;
	esac
	
	# if there is no "always_build_from_src" line in "$state_dir/spm/config",
	# 	and "$always_build_from_src" is not set,
	# 	and the corresponding directory for the current architecture is available in $build_url,
	# 	just download that into "$cache_dir/spm/builds-dl/$gn_namespace/$pkg_name"
	# then spm_build all the packages mentioned in the included "spmdeps" file
	# then hardlink the downloaded files plus the the packages mentioned in "spmdeps" file, into "$build_dir"
	# and thats it, return
	
	# try to download the package from "$pkg_url" to "$pkg_dir/"
	# if not root, before downloading a package first see if it already exists in /var/cache/spm/builds-dl/
	# if so, sudo spm update <package-url>, then make hard links in ~/.cache/spm/builds-dl/
	
	# if "$build_dir" dir exists and its mod time is newer compared to "$pkg_dir", return
	
	# if "Build.sh" file is already open, it means that there is a cyclic dependency
	# so warn and exit to avoid an infinite loop
	
	pkg__$pkg_name="$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name"
	# packages needed as dependency, are mentioned in the "Build.sh" script, like this:
	# 	spm_build <gnunet-namespace> [<package-name>]
	# now we can use "$pkg_<package-name>" where ever you want to access a file in a package
	
	# for run'time dependencies:
	# 	spm_include <gnunet-namespace> <package-name>
	# this is what it does:
	# , appends the URL of the package to ".cache/spm/builds/spmdeps" (if not already)
	# , creates a hard'link from packages mentioned in spmdeps, if the mod time is newer
	
	. "$pkg_dir"/Build.sh
}

spm_include() {
	# build then create hardlinks
}

spm_install() {
	pkg_url="gnunet://fs/sks/$1/packages/$2"
	
	pkg_name="$3"
	[ -z "$3" ] && pkg_name="$2"
	
	pkg_dir="$packages_dir/$pkg_name"
	
	spm_build "$pkg_id"
	
	# if "$pkgs_dir/<gnunet-namespace>/<package-name>/" already exists:
	# , create "$pkgs_dir/<gnunet-namespace>/<namespace>-new/" directory
	# , at the end: exch "$pkgs_dir/<gnunet-namespace>/<namespace>-new/" "$pkgs_dir/<gnunet-namespace>/<namespace>/"
	
	# create hard links from files (recursively) in
	# 	"$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name/.cache/spm/builds/<arch>/",
	# 	to "$pkgs_dir/<gnunet-namespace>/<package-name>/"
	
	# the GNUnet URL is stored in "$pkg_dir/pkg_url" file
	# this will be used to update the app
	
	# for files in "$pkg_dir/exp/cmd/*":
	# chmod +x file
	# if the file name has no extention, symlink into "$cmd_dir"
	# if the file name has an extention:
	# , if [ $(id -u) != 0 ]; then in the first line replace #!/exp/cmd/env with #!/usr/bin/env  
	# , symlink it into "$cmd_dir" (without extention)
	
	# create symlinks from "$pkg_dir/exp/cmd/*"
	# files into "$apps_dir"
	
	# create symlinks from "$pkg_dir/exp/dbus/*" directories
	# to "$dbus_dir"
	
	[ "$(id -u)" = 0 ] || return 0
	
	# create symlinks from "$pkg_dir/exp/sv/*" directories, to "$sv_dir"
	
	# when package is $gnunet_namespace/limine
	# mount first partition of the device where this script resides, and copy efi and sys files to it
	boot_dir="$(mktemp -d)"
	mount "$root_device_partition1" "$boot_dir"
	trap "trap - EXIT; umount \"$boot_dir\"; rmdir \"$boot_dir\"" EXIT INT TERM QUIT HUP PIPE
	mkdir -p "$boot_dir"/EFI/BOOT
	# copy efi file to "$boot_dir"/EFI/BOOT/
	umount "$boot_dir"; rmdir "$boot_dir"
	
	if [ "$ARCH" = x86 ] || [ "$ARCH" = x86_64 ]; then
		"$cmd_dir"/limine bios-install "$target_device"
	elif [ "$ARCH" = ppc64le ]; then
		# only OPAL Petitboot based systems are supported
		cat <<-EOF > "$boot_dir"/syslinux.cfg
		PROMPT 0
		LABEL SPM Linux
			LINUX vmlinuz
			APPEND root=UUID=$(blkid /dev/"$root_device_partition2" | sed -rn 's/.*UUID="(.*)".*/\1/p') rw
			INITRD initramfs.img
		EOF
	fi
	
	# when package is $gnunet_namespace/linux
	# mount first partition of the device where this script resides, and copy the kernel and initramfs to it
	# umount
}

if [ "$1" = build ]; then
	always_build_from_src=1
	if [ -z "$2" ]; then
		spm_build .
	elif [ -f "$2/Build.sh" ]; then
		spm_build "$2"
	else
		# search for "Build.sh" in child directories of "$2"
		# the first one found plus its siblings are the packages to be built
		# run spm_build and spm_test for each
	fi
elif [ "$1" = install ]; then
	spm_install "$2" "$3"
elif [ "$1" = remove ]; then
	pkg_name="$2"
	pkg_dir="$packages_dir/$pkg_name"
	url="$(cat "$pkg_dir/pkg_url")"
	
	if [ "$(id -u)" = 0 ]; then
		# exit if package_name is: acpid bash bluez chrony dash dbus dte eudev fwupd gnunet limine linux netman runit
		# 	sbase sd seatd spm sudo tz util-linux
		# warn if package_name is sway, swapps, termulator, or codev
	fi
	
	# removes the files mentioned in "$pkg_dir/exp/cmd" from "$cmd_dir"
	
	# remove symlinks in "$root_dir/exp/apps/" corresponding to
	# "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/apps/*.desktop"
	
	# remove symlinks in "$root_dir/exp/sv/" corresponding to
	# "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/sv/*"
	
	# , removes "$root_dir/packages/<gnunet-namespace>/<package-name>" directory
elif [ "$1" = update ]; then
	# for each gnunet_namespace/package_name directory in $packages_dir
	# spm_install "$url" "$package_name"
	
	# check in each update, if the ref count of files in .cache/spm/builds is 1, clean that package
	# file_ref_count=$(stat -c %h filename)
	
	# when the namespace directory is empty, delete it
	
	# fwupd
	# boot'firmware updates need special care
	# unless there is a read'only backup, firmware update is not a good idea
	# so warn and ask the user if she wants the update
	# doas fwupdmgr get-devices
	# doas fwupdmgr refresh
	# doas fwupdmgr get-updates
	# doas fwupdmgr update
	
	if [ "$arch" = x86 ] || [ "$arch" = x86_64 ]; then
		limine bios-install "$target_device"
	fi
elif [ "$1" = publish ]; then
	# make a BTRFS snapshot from the project's directory,
	# to "~/.local/spm/published/$gnunet_namespace/$pkg_name"
	
	# ".data/gnurl" stores the project's GNUnet URL: gnunet://fs/sks/<name-space>/projects/<project_name>
	# package URL is obtained from it like this: gnunet://fs/sks/<name-space>/packages/<project_name>
	
	# publish "~/.local/spm/published/$gnunet_namespace/$pkg_name" (minus the ".cache" directory) to:
	# "gnunet://fs/sks/<namespace>/packages/<package-name>/"
	
	# cross'built the package for all architectures mentioned in "$state_dir/spm.conf" (value of "arch" entry),
	# and put the results in in ".cache/spm/builds/<arch>/"
	# in "spmbuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "spmdeps" file, plus all files in ".cache/spm/builds/<arch>/" minus "deps" directory,
	# and put them in ".cache/spm/builds-published/<arch>/"
	
	# publish ".cache/spm/builds-published/<arch>/" to:
	# "gnunet://fs/sks/<namespace>/packages_build/<package-name>/<arch>"
	
	# the "spmbuild.sh" file will be published into the GNUnet namespace
	# the source files can be in the same place, or in a Git URL
	# 	in which case, there must be a "git clone <git-url> .cache/git" line, in the "spmbuild.sh" file
elif [ "$1" = install-spmlinux ]; then
	. "$script_dir"/install.sh
else
	echo "usage guide:"
	echo "	spm build [<project-path>]"
	echo "	spm install <gnunet-url> [<package-name>]"
	echo "	spm remove <package-name>"
	echo "	spm update"
	echo "	spm publish"
	echo "	spm install-spmlinux"
fi
