#!/usr/bin/env sh
set -e

# https://en.wikipedia.org/wiki/GoboLinux
# https://gobolinux.org/
# https://gobolinux.org/doc/articles/clueless.html
# https://github.com/gobolinux

# if gnunet is not available, use gitea (through its http api)
# files must be signed (with ssh-keygen)
# hash of files followed by their path (relative to projet dir) are stored in .gitea file
# this file will be used during download and publish, such that only changed files will be transfered

# mount with read-write access only for processes running with a specific group id
# sd mount <group-id>

# spm check
# check if any git source needs an update
# https://stackoverflow.com/questions/1064499/how-to-list-all-git-tags

# to verify git tag signatures use ssh-keygen
# git config --global gpg.format ssh
# echo "$(git config --get user.email) namespaces=\"git\" $(cat "$path_to_ssh_public_key")
# " >> "$path_to_allowed_signers_file"
# git config --global gpg.ssh.allowedSignersFile "$path_to_allowed_signers_file"
# https://blog.dbrgn.ch/2021/11/16/git-ssh-signatures/
# https://www.git-tower.com/blog/setting-up-ssh-for-commit-signing/
# https://calebhearth.com/sign-git-with-ssh
# https://github.com/git/git/blob/master/Documentation/config/gpg.adoc
# https://git-scm.com/docs/git-verify-tag
# https://lobi.to/writes/wacksigning/

[ -z "$ARCH" ] && ARCH="$(uname --machine)"

# cpu arch: uname --machine
# kernel name: uname --kernel-name

script_dir="$(dirname "$(realpath "$0")")"

root_dir="$script_dir/../../../../../.."
if [ "$(id -u)" = 0 ] || [ "$(id -u)" = 1 ]; then
	builds_dir="$root_dir/var/lib/spm/builds"
	cmd_dir="$root_dir/usr/bin"
	sv_dir="$root_dir/usr/share/sv"
	dbus_dir="$root_dir/usr/share/dbus-1" # dbus interfaces and services
	apps_dir="$root_dir/usr/share/applications" # system services
	state_dir="$root_dir/var/lib"
	cache_dir="$root_dir/var/cache"
else
	builds_dir="$HOME/.local/state/spm/builds"
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

mkdir -p "$builds_dir" "$cmd_dir" "$sv_dir" "$dbus_dir" "$apps_dir" "$state_dir" "$cache_dir"

# this function can be used in SPMbuild.sh scripts to clone a tag branch from a git repository
gitag_clone() {
	# https://man.archlinux.org/listing/git
	
	# https://git-scm.com/docs/partial-clone
	
	# --depth 1
	
	# lsh-keygen/ssh-keygen to verify git tags
	# https://git-scm.com/docs/git-verify-tag
	# https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgltformatgtprogram
	# https://manpages.debian.org/bookworm/lsh-utils/lsh-keygen.1.en.html
	# https://manpages.debian.org/bookworm/openssh-client/ssh-keygen.1.en.html
	
	# if a gpg key is given, download and build gpg package
}

# programs installed in ~/.local/bin and the SPMbuild.sh scripts when current user is 1000,
# will be run as user 1001

# this function can be used in SPMbuild.sh scripts to export executables in $pkg_dir/exec
# usage guide:
# spm_xcript <executable-name> exp/cmd
# spm_xcript <executable-name> inst/cmd
# spm_xcript <executable-name> inst/app
spm_xcript() {
	local executable_name="$1"
	local destination_dir_relpath="$2"
	local destination_path="$script_dir/.cache/spm/build/$ARCH/$destination_dir_relpath/$executable_name"
	
	mkdir -p "$script_dir/.cache/spm/build/$ARCH/$destination_dir_relpath"
	
	cat <<-'EOF' > "$destination_path"
	#!/usr/bin/env sh
	script_dir="$(dirname "$(realpath "$0")")"
	export PATH="$script_dir/../../exec:$PATH"
	export LD_LIBRARY_PATH="$script_dir/../../lib"
	export XDG_DATA_DIRS="$script_dir/../../data"
	EOF
	
	echo "exec \$script_dir/../../exec/$executable_name" >> "$destination_path"
	chmod +x "$destination_path"
}

spm_download() {
	local gn_namespace="$1"
	local pkg_name="$2"
	local pkg_name_build="$pkg_name-$ARCH"
	# download directories
	local dl_dir="$cache_dir/spm/packages/$gn_namespace/$pkg_name"
	local dl_build_dir="$cache_dir/spm/$ARCH/$gn_namespace/$pkg_name"
	
	# if gn-download is not available (which is the case during first installation), just use normal gnunet download
	
	# if there is no line equal to "build'from'src" in "$state_dir/spm/config"
	# 	download $pkg_name_build from $gn_namespace into "$dl_build_dir"
	# 	result="$(gn-download "$gn_namespace" "$pkg_namebuild" "$dl_build_dir")"
	# 	[ result = "not fount" ] || return
	# download the package from "$pkg_url" to "$dl_dir"
	# gn-download "$gn_namespace" "$pkg_name" "$dl_dir"
	# when gn-download is not available use "$script_dir"/../gnunet/gnunet-download.sh
	
	# when building from source to be installed on system:
	# use -march=native for clang
	# pass CPU specific flags
}

spm_build() {
	local pkg_dir= build_dir= gn_namespace= pkg_name=
	local spmbuildsh_dir="$pkg_dir"
	
	if [ -z "$2" ]; then
		pkg_dir="$1"
		build_dir="$pkg_dir/.cache/spm/build/$TARGET/$pkg_name"
		
		SPM_TEST=1
		# at the end of SPMbuild.sh scripts, we can include test instructions, after this line:
		# [ -z SPM_TEST ] && return
		
		# read the gnunet namespace in $pkg_dir/.data/gnunet
		GNNS=
	else
		gn_namespace="$1"
		pkg_name="$2"
		build_dir="$state_dir/spm/build/$gn_namespace/$pkg_name"
		
		# if gn_namespace is revoked try the alternative ones from .data/gnunet/$gn_namespace
		# also print a warning
		
		if [ "$(id -u)" = 0 ]; then
			spm_download $gn_namespace $pkg_name
		else
			sudo spm download $gn_namespace $pkg_name
		fi
		
		eval PKG$pkg_name="\"$build_dir\""
		# packages needed as dependency, are mentioned in the "SPMbuild.sh" script, like this:
		# 	spm_build <gnunet-namespace> <package-name>
		# now we can use "$PKG<package-name>" where ever you want to access a file in a package
		
		# if prebuild package is downloaded:
		# spm_import all the packages mentioned in the "imp" file
		# and thats it, return
		
		# if "SPMbuild.sh" file is already open, it means that there is a cyclic dependency
		# so just download a prebuilt package (even when "build'from'src" is in config)
		# then warn and return, to avoid an infinite loop
	fi
	
	# if "$build_dir" already exists:
	# , create "${build_dir}-new"
	# , at the end: exch "${build_dir}-new" "$build_dir"
	
	. "$pkg_dir"/SPMbuild.sh
}

# this function can be used in SPMbuild.sh scripts to import run'time dependency packages
spm_import() {
	local gn_namespace="$1"
	local pkg_name="$2"
	[ -z "$2" ] && {
		# read gn_namespace from the first line of ".data/gnunet/project"
		gn_namespace=
		pkg_name="$1"
	}
	
	spm_build "$gn_namespace" "$pkg_name"
	# symlink (relative path) the files in "$PKG$pkg_name/cmd" "$PKG$pkg_name/lib" and "$PKG$pkg_name/data" into:
	# 	"$build_dir/exec" "$build_dir/lib" and "$build_dir/data"
	# do not symlink symlinks; make a symlink to the origin
	
	# append the URL of the package to ".cache/spm/builds/imp" (if not already)
	
	# increment the number stored in spmcount file
	
	# imports:
	# , libs: symlink the files listed in $dep_pkg_dir/exp/lib into $pkg_dir/lib
	# , commands: symlink the files listed in $dep_pkg_dir/exp/cmd into $pkg_dir/cmd
	# , lib data (like fonts and icons):
	# 	symlink the data directories listed in $dep_pkg_dir/exp/data into $pkg_dir/data
}

spm_install() {
	local gn_namespace="$1"
	local pkg_name="$2"
	local build_dir="$builds_dir/$gn_namespace/$pkg_name"
	
	if [ "$(id -u)" = 0 ]; then
		# create build dir and set the owner as user 1
		sudo -u1 spm build "$gn_namespace" "$pkg_name"
	else
		spm_build "$pkg_n ame"
	fi
	
	# store "$gn_namespace $pkg_name" in $state_dir/spm/installed (if not already)
	# if $pkg_name exists already, and namespaces does not match, but owners match, replace,
	# 	otherwise exit with error
	
	# if a symlink with the same name already exists:
	# if it's linked into the same package, skip
	# otherwise if the owners match, replace then, otherwise exit with error
	
	# create symlinks from "$build_dir/inst/cmd/*" files into "$cmd_dir"
	
	# create .desktop files from "$build_dir/inst/app/*" files into "$apps_dir"
	# .desktop file name: $pkg_name.$app_name.desktop
	# icon_path=""
	# [Desktop Entry]
	# Type=Application
	# StartupNotify=true
	# Name=$app_name
	# Icon=$(echo $build_dir/inst/app/$app_name.*)
	# Exec=$build_dir/inst/app/$app_name
	
	# create symlinks from "$build_dir/inst/dbus/*" directories to "$dbus_dir"
	
	[ "$(id -u)" = 0 ] || return 0
	
	# create symlinks from "$build_dir/inst/sv/*" directories, to "$sv_dir"
	
	# when package is $gnunet_namespace/limine
	# mount first partition of the device where this script resides, and copy efi and sys files to it
	{
		boot_dir="$(mktemp -d)"
		mount "$root_device_partition1" "$boot_dir"
		trap "trap - EXIT; umount \"$boot_dir\"; rmdir \"$boot_dir\"" EXIT INT TERM QUIT HUP PIPE
		mkdir -p "$boot_dir"/EFI/BOOT
		
		# copy efi file to "$boot_dir"/EFI/BOOT/
		
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
	}
	
	# when package is $gnunet_namespace/kernel
	# link modules to /lib/modules
	# mount first partition of the device where this script resides, and copy the kernel and initramfs to it
	{
		mount "$root_device_partition1" "$boot_dir"
		trap "trap - EXIT; umount \"$boot_dir\"; rmdir \"$boot_dir\"" EXIT INT TERM QUIT HUP PIPE
	}
}

if [ "$1" = build ]; then
	if [ -z "$3" ]; then
		project_dir="$2"
		[ -z "$project_dir" ] && project_dir=.
			
		if [ -f "$2/SPMbuild.sh" ]; then
			spm_build "$project_dir"
		else
			# search for "SPMbuild.sh" (case insensitive) in "$project_dir"
			# the first one found, plus those sibling directories containing a SPMbuild.sh, are the packages to be built
			# run spm_build for each
		fi
	else
		spm_build "$2" "$3"
	fi
elif [ "$1" = import ]; then
	spm_import "$2" "$3"
elif [ "$1" = install ]; then
	spm_install "$2" "$3"
elif [ "$1" = remove ]; then
	gn_namespace="$2"
	pkg_name="$3"
	pkg_dir="$builds_dir/$gn_namespace/$pkg_name"
	
	if [ "$(id -u)" = 0 ]; then
		# exit if package_name is: acpid bash bluez chrony dash dbus dte eudev fwupd gnunet limine linux netman runit
		# 	sbase sd seatd spm sudo tz util-linux
		# warn if package_name is sway, swapps, termulator, or codev
	fi
	
	# for packages mentioned in "imp" file:
	# , decrement the number stored in their spmcount file
	# , if the number gets zero, and it's not in $state_dir/spm/installed file, remove that package too
	
	# remove it from $state_dir/spm/installed file, but remove the package dir, only if spmcount is zero
	
	# removes the files mentioned in "$pkg_dir/exp/cmd" from "$cmd_dir"
	
	# remove symlinks in "$root_dir/exp/apps/" corresponding to
	# "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/apps/*.desktop"
	
	# remove symlinks in "$root_dir/exp/sv/" corresponding to
	# "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/sv/*"
	
	# , removes "$root_dir/packages/<gnunet-namespace>/<package-name>" directory
elif [ "$1" = update ]; then
	# for each line in $state_dir/spm/installed
	# spm_install "$gn_namespace" "$package_name"
	
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
	
	if [ "$ARCH" = x86 ] || [ "$ARCH" = x86_64 ]; then
		limine bios-install "$target_device"
	fi
elif [ "$1" = publish ]; then
	# make a BTRFS snapshot from the project's directory,
	# to "~/.local/spm/publish/$gnunet_namespace/$pkg_name"
	
	# ".data/gnunet" stores the project's GNUnet namespace and poject name
	# sks identifier to publish pakage: <project_name>-pkg-<number>
	
	gn-publish "~/.local/spm/published/$gnunet_namespace/$pkg_name" $gnunet_namespace $pkg_name-pkg
	
	# cross'built the package for all architectures mentioned in "$state_dir/spm.conf" (value of "arch" entry),
	# and put the results in in ".cache/spm/builds/<arch>/"
	# in "SPMbuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "imp" file, plus all files in ".cache/spm/builds/<arch>/" minus "imp" directory,
	# and put them in ".cache/spm/builds-published/<arch>/"
	
	gn-publish ".cache/spm/builds-published/<arch>/" $gnunet_namespace $pkg_name-$ARCH
	
	# the "SPMbuild.sh" file will be published into the GNUnet namespace
	# the source files can be in the same place, or in a Git URL
	# 	in which case, there must be a "git clone <git-url> .cache/git" line, in the "SPMbuild.sh" file
	
	# watch for releases of a package's git repository
	# https://release-monitoring.org/
elif [ "$1" = install-spmlinux ]; then
	. "$script_dir"/install.sh
else
	echo "usage guide:"
	echo "	spm build [<project-path>]"
	echo "	spm build <gnunet-namespace> <package-name>"
	echo "	spm import <gnunet-namespace> <package-name>"
	echo "	spm download <gnunet-namespace> <package-name>"
	echo "	spm install <gnunet-namespace> <package-name>"
	echo "	spm remove <gnunet-namespace> <package-name>"
	echo "	spm update"
	echo "	spm publish"
	echo "	spm install-spmlinux"
fi
