#!/usr/bin/env sh

script_dir="$(dirname "$(readlink -f "$0")")"

. "$script_dir"/upm-alpine.sh; exit

# https://en.wikipedia.org/wiki/GoboLinux
# https://gobolinux.org/
# https://gobolinux.org/doc/articles/clueless.html
# https://github.com/gobolinux

# if run by non'root
# if bubblewrap is available, run Ubuild.sh inside bubblewrap sandbox,
# 	which have write access only to it's own installation dir
# https://wiki.archlinux.org/title/Bubblewrap/Examples

# reproducible builds
# during building, a file will be created that contains all the build dependencies and their versions,
# 	in the order mensioned in the Ubuild.sh file
# if this file is equal to the one in the official gnunet namespace,
# 	the built files will be compared (using the CHK of files in gnunet),
# 	and if there is any incompatabilities, the user will be notified

# ROOT_DIR

[ -z "$ARCH" ] && ARCH="$(uname --machine)"

if [ "$(id -u)" = 0 ] || [ "$(id -u)" = 1 ]; then
	builds_dir="$ROOT_DIR/var/lib/upm/builds"
	cmd_dir="$ROOT_DIR/usr/bin"
	sv_dir="$ROOT_DIR/usr/share/sv"
	dbus_dir="$ROOT_DIR/usr/share/dbus-1" # dbus interfaces and services
	apps_dir="$ROOT_DIR/usr/share/applications" # system services
	state_dir="$ROOT_DIR/var/lib"
	cache_dir="$ROOT_DIR/var/cache"
else
	builds_dir="$HOME/.local/state/upm/builds"
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

# this function can be used in Ubuild.sh scripts to clone a tag branch from a git repository
gitag_clone() {
	# https://man.archlinux.org/listing/git
	
	# https://git-scm.com/docs/partial-clone
	
	# --depth 1
	
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
	#
	# if a gpg key is given, download and build gpg package
}

# this function can be used in Ubuild.sh scripts to export executables in $pkg_dir/exec
# usage guide:
# upm_xcript <executable-name> exp/cmd
# upm_xcript <executable-name> inst/cmd
# upm_xcript <executable-name> inst/app
upm_xcript() {
	local executable_name="$1"
	local destination_dir_relpath="$2"
	local destination_path="$script_dir/.cache/upm/build/$ARCH/$destination_dir_relpath/$executable_name"
	
	mkdir -p "$script_dir/.cache/upm/build/$ARCH/$destination_dir_relpath"
	
	cat <<-'EOF' > "$destination_path"
	#!/usr/bin/env sh
	script_dir="$(dirname "$(readlink -f "$0")")"
	export PATH="$script_dir/../../exec:$PATH"
	export LD_LIBRARY_PATH="$script_dir/../../lib"
	export XDG_DATA_DIRS="$script_dir/../../data"
	EOF
	
	echo "exec \$script_dir/../../exec/$executable_name" >> "$destination_path"
	chmod +x "$destination_path"
}

upm_download() {
	local gn_namespace="$1"
	local pkg_name="$2"
	local pkg_name_build="$pkg_name-$ARCH"
	# download directories
	local dl_dir="$cache_dir/upm/packages/$gn_namespace/$pkg_name"
	local dl_build_dir="$cache_dir/upm/$ARCH/$gn_namespace/$pkg_name"
	
	# if there is no line equal to "build'from'src" in "$state_dir/upm/config"
	# 	download $pkg_name_build from $gn_namespace into "$dl_build_dir"
	# 	result="$(gn-download "$gn_namespace" "$pkg_namebuild" "$dl_build_dir")"
	# 	[ result = "not fount" ] || return
	# download the package from "$pkg_url" to "$dl_dir"
	# gn-download "$gn_namespace" "$pkg_name" "$dl_dir"
}

upm_build() {
	local pkg_dir= build_dir= gn_namespace= pkg_name=
	local upmbuildsh_dir="$pkg_dir"
	
	if [ -z "$2" ]; then
		pkg_dir="$1"
		build_dir="$pkg_dir/.cache/upm/build/$TARGET/$pkg_name"
		
		UPM_TEST=1
		# at the end of UPMbuild.sh scripts, we can include test instructions, after this line:
		# [ -z UPM_TEST ] && return
		
		# read the gnunet namespace in $pkg_dir/.data/gnunet
		GNNS=
	else
		gn_namespace="$1"
		pkg_name="$2"
		build_dir="$state_dir/upm/build/$gn_namespace/$pkg_name"
		
		# if gn_namespace is revoked try the alternative ones from .data/gnunet/$gn_namespace
		# also print a warning
		
		if [ "$(id -u)" = 0 ]; then
			upm_download $gn_namespace $pkg_name
		else
			doas upm download $gn_namespace $pkg_name
		fi
		
		eval PKG$pkg_name="\"$build_dir\""
		# packages needed as dependency, are mentioned in the "UPMbuild.sh" script, like this:
		# 	upm_build <gnunet-namespace> <package-name>
		# now we can use "$PKG<package-name>" where ever you want to access a file in a package
		
		# if prebuild package is downloaded:
		# upm_import all the packages mentioned in the "imp" file
		# and thats it, return
		
		# if "UPMbuild.sh" file is already open, it means that there is a cyclic dependency
		# so just download a prebuilt package (even when "build'from'src" is in config)
		# then warn and return, to avoid an infinite loop
	fi
	
	# if "$build_dir" already exists:
	# , create "${build_dir}-new"
	# , at the end: exch "${build_dir}-new" "$build_dir"
	
	. "$pkg_dir"/UPMbuild.sh
}

# this function can be used in Ubuild.sh scripts to import run'time dependency packages
upm_import() {
	local gn_namespace="$1"
	local pkg_name="$2"
	[ -z "$2" ] && {
		# read gn_namespace from the first line of ".data/gnunet/project"
		gn_namespace=
		pkg_name="$1"
	}
	
	upm_build "$gn_namespace" "$pkg_name"
	# symlink (relative path) the files in "$PKG$pkg_name/cmd" "$PKG$pkg_name/lib" and "$PKG$pkg_name/data" into:
	# 	"$build_dir/exec" "$build_dir/lib" and "$build_dir/data"
	# do not symlink symlinks; make a symlink to the origin
	
	# append the URL of the package to ".cache/upm/builds/imp" (if not already)
	
	# increment the number stored in upmcount file
	
	# imports:
	# , libs: symlink the files listed in $dep_pkg_dir/exp/lib into $pkg_dir/lib
	# , commands: symlink the files listed in $dep_pkg_dir/exp/cmd into $pkg_dir/cmd
	# , lib data (like fonts and icons):
	# 	symlink the data directories listed in $dep_pkg_dir/exp/data into $pkg_dir/data
}

upm_install() {
	local gn_namespace="$1"
	local pkg_name="$2"
	local build_dir="$builds_dir/$gn_namespace/$pkg_name"
	
	if [ "$(id -u)" = 0 ]; then
		# create build dir and set the owner as user 10
		setpriv --reuid=10 --regid=10 --inh-caps=-all upm build "$gn_namespace" "$pkg_name"
	else
		upm_build "$gn_namespace" "$pkg_name"
	fi
	
	# store "$gn_namespace $pkg_name" in $state_dir/upm/installed (if not already)
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
	
	# when package is $gnunet_namespace/systemd-boot or linux
	# run bootup.sh
	
	# when package is $gnunet_namespace/linux
	# link modules to /lib/modules
}

upm_search() {
	# search in gnunet for extra packages
}

upm_list() {
	# list installed packages filterd by $1
}

if [ "$1" = build ]; then
	if [ -z "$3" ]; then
		project_dir="$2"
		[ -z "$project_dir" ] && project_dir=.
			
		if [ -f "$2/Ubuild.sh" ]; then
			upm_build "$project_dir"
		else
			# search for "Ubuild.sh" (case insensitive) in "$project_dir"
			# the first one found, plus those sibling directories containing a Ubuild.sh, are the packages to be built
			# run upm_build for each
		fi
	else
		upm_build "$2" "$3"
	fi
elif [ "$1" = import ]; then
	upm_import "$2" "$3"
elif [ "$1" = install ]; then
		upm_install "$2" "$3"
elif [ "$1" = remove ]; then
	gn_namespace="$2"
	pkg_name="$3"
	pkg_dir="$builds_dir/$gn_namespace/$pkg_name"
	
	if [ "$(id -u)" = 0 ]; then
		# exit if package_name is: acpid bash bluez chrony dash dbus dte eudev fwupd gnunet systemd-boot linux netman dinit
		# 	sbase upm doas tz util-linux
		# warn if package_name is sway, swapps, termulator, or uni
	fi
	
	# for packages mentioned in "imp" file:
	# , decrement the number stored in their upmcount file
	# , if the number gets zero, and it's not in $state_dir/upm/installed file, remove that package too
	
	# remove it from $state_dir/upm/installed file, but remove the package dir, only if upmcount is zero
	
	# removes the files mentioned in "$pkg_dir/exp/cmd" from "$cmd_dir"
	
	# remove corresponding symlinks in "$apps_dir" and "$sv_dir"
	
	# remove package directory
elif [ "$1" = update ]; then
	# for each line in $state_dir/upm/installed
	# upm_install "$gn_namespace" "$package_name"
	
	# check in each update, if the ref count of files in .cache/upm/builds is 1, clean that package
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
elif [ "$1" = check ]; then
	# check if any git source needs an update
	# https://stackoverflow.com/questions/1064499/how-to-list-all-git-tags
elif [ "$1" = mkinst ]; then
	. "$script_dir"/mkinst.sh "$2"
elif [ "$1" = publish ]; then
	# make a BTRFS snapshot from the project's directory,
	# to "~/.local/upm/publish/$gnunet_namespace/$pkg_name"
	
	# ".data/gnunet" stores the project's GNUnet namespace and poject name
	# sks identifier to publish pakage: <project_name>-pkg-<number>
	
	gn-publish "~/.local/upm/published/$gnunet_namespace/$pkg_name" $gnunet_namespace $pkg_name-pkg
	
	# cross'built the package for all architectures mentioned in "$state_dir/upm.conf" (value of "arch" entry),
	# and put the results in in ".cache/upm/builds/<arch>/"
	# in "Ubuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "imp" file, plus all files in ".cache/upm/builds/<arch>/" minus "imp" directory,
	# and put them in ".cache/upm/builds-published/<arch>/"
	
	gn-publish ".cache/upm/builds-published/$ARCH/" $gnunet_namespace $pkg_name-$ARCH
	
	# the "Ubuild.sh" file will be published into the GNUnet namespace
	# the source files can be in the same place, or in a Git URL
	# 	in which case, there must be a "git clone <git-url> .cache/git" line, in the "Ubuild.sh" file
	
	# watch for releases of a package's git repository
	# https://release-monitoring.org/
else
	echo "usage guide:"
	echo "	upm build [<project-path>]"
	echo "	upm build <gnunet-namespace> <package-name>"
	echo "	upm import <gnunet-namespace> <package-name>"
	echo "	upm download <gnunet-namespace> <package-name>"
	echo "	upm install <gnunet-namespace> <package-name>"
	echo "	upm remove <gnunet-namespace> <package-name>"
	echo "	upm update"
	echo "	upm check"
	echo "	upm mkinst"
	echo "	upm publish"
fi
