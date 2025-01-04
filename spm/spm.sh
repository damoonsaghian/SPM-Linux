#!/exp/cmd/env sh
set -e

[ -z "$ARCH" ] && ARCH="$(uname --machine)"

script_dir="$(dirname "$(realpath "$0")")"

root_dir="$script_dir/../../../../../.."
if [ "$(id -u)" = 0 ] || [ "$(id -u)" = 1 ] || [ "$(id -u)" = 2 ]; then
	builds_dir="$root_dir/var/lib/spm/builds"
	cmd_dir="$root_dir/inst/cmd"
	sv_dir="$root_dir/inst/sv"
	dbus_dir="$root_dir/inst/dbus" # dbus interfaces and services
	apps_dir="$root_dir/inst/apps" # system services
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
	
	# lsh-keygen/ssh-keygen to verify git tags
	# https://git-scm.com/docs/git-verify-tag
	# https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgltformatgtprogram
	# https://manpages.debian.org/bookworm/lsh-utils/lsh-keygen.1.en.html
	# https://manpages.debian.org/bookworm/openssh-client/ssh-keygen.1.en.html
	
	# if a gpg key is given, download and build gpg package
}

# each project contains a SPMns file whose first line is: <gnunet-namespace> <package-name>
# the following line contains alternative gnunet namespaces
# some of them can be reserved namespaces; ie they can have no package with that name
# before updating a package, first we compare SPMns files
# if they match, it will be downloaded, and then we go to the next namespaces which must have the same content
# 	if not the content that most namespaces agree on, will be the downloaded result
# but if SPMns files don't match, the SPMns that most namespaces agree on, will be chosen
# when the main (ie the first) namespace is invalidated according to the above mechanism
# , if it is in $state_dir/spm/installed, replace it with the new namespace
# , if it's built as a dependecy, make a symlink from new download dir inplace of the old one

# in SPMbuild.sh scripts, to create executable scripts,
# in the first line replace #!/exp/cmd/env with #!/usr/bin/env, then make it executable

# programs installed in ~/.local/bin and the SPMbuild.sh scripts when current user is 1000,
# will be run as user 1001

# this function can be used in SPMbuild.sh scripts to export executables in $pkg_dir/exec
# usage guide:
# spm_xport <executable-name> exp/cmd
# spm_xport <executable-name> inst/cmd
# spm_xport <executable-name> inst/app
spm_xport() {
	local executable_name="$1"
	local destination_dir_relpath="$2"
	local destination_path="$script_dir/.cache/spm/builds/$ARCH/$destination_dir_relpath/$executable_name"
	
	if [ cmd_dir = "$HOME/.local/bin" ]; then
		# adding "/usr/bin:/bin:/usr/sbin:/sbin" to PATH is for when SPM is installed at HOME
		cat <<-'EOF' > "$destination_path"
		#!/inst/cmd/env sh
		script_dir="$(dirname "$(realpath "$0")")"
		export PATH="$script_dir/../../exec:$HOME/.local/bin:/inst/cmd"
		PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
		export LD_LIBRARY_PATH="$script_dir/../../lib"
		export XDG_DATA_DIRS="$script_dir/../../data"
		EOF
	else
		# adding "/usr/bin:/bin:/usr/sbin:/sbin" to PATH may be useful for cyclic dependencies when bootstraping
		cat <<-'EOF' > "$destination_path"
		#!/inst/cmd/env sh
		script_dir="$(dirname "$(realpath "$0")")"
		export PATH="$script_dir/../../exec:$script_dir/../../../../../../../../inst/cmd"
		PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
		export LD_LIBRARY_PATH="$script_dir/../../lib"
		export XDG_DATA_DIRS="$script_dir/../../data"
		EOF
	fi
	
	echo "\$script_dir/../../exec/$executable_name" >> "$destination_path"
	chmod +x "$destination_path"
}

spm_download() {
	local gn_namespace="$1"
	local pkg_name="$2"
	local pkg_url="gnunet://fs/sks/$gn_namespace/packages/$pkg_name"
	local build_url="gnunet://fs/sks/$gn_namespace/builds/$pkg_name"
	# download directories
	local dl_dir="$cache_dir/spm/packages/$gn_namespace/$pkg_name"
	local dl_build_dir="$cache_dir/spm/builds/$ARCH/$gn_namespace/$pkg_name"
	
	# if there is no "download'src" line in "$state_dir/spm/config",
	# 	and "$download_src" is not set, and $build_url exists,
	# 	download that into "$dl_build_dir"
	# else: download the package from "$pkg_url" to "$dl_dir"
}

spm_build() {
	local pkg_dir= build_dir= gn_namespace= pkg_name=
	
	if [ -z "$2" ]; then
		pkg_dir="$1"
		build_dir="$pkg_dir/.cache/spm/builds/$ARCH/$pkg_name"
		
		SPM_TEST=1
		# at the end of SPMbuild.sh scripts, we can include test instructions, after this line:
		# [ -z SPM_TEST ] && return
	else
		gn_namespace="$1"
		pkg_name="$2"
		build_dir="$state_dir/spm/builds/$gn_namespace/$pkg_name"
		
		if [ "$(id -u)" = 0 ]; then
			spm_download $gn_namespace $pkg_name
		else
			sudo spm download $gn_namespace $pkg_name
		fi
		
		eval PKG$pkg_name="\"$build_dir\""
		# packages needed as dependency, are mentioned in the "Build.sh" script, like this:
		# 	spm_build <gnunet-namespace> <package-name>
		# now we can use "$PKG<package-name>" where ever you want to access a file in a package
		
		# if prebuild package is downloaded:
		# spm_import all the packages mentioned in the "imp" file
		# and thats it, return
		
		# if "SPMbuild.sh" file is already open, it means that there is a cyclic dependency
		# so warn and return, to avoid an infinite loop
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
	
	if [ "$(id -u)" = 0 ] && [ "$3" = core ]; then
		sudo -u1 spm build "$gn_namespace" "pkg_name"
	else
		spm_build "$pkg_name"
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
	# Name=$app_name
	# Icon=$(echo $build_dir/inst/app/$app_name.*)
	# Exec=$build_dir/inst/app//$app_name
	
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
	
	# when package is $gnunet_namespace/linux
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
			# search for "SMPbuild.sh" in child directories of "$project_dir"
			# the first one found, plus its siblings, are the packages to be built
			# run spm_build for each
		fi
	else
		spm_build "$2" "$3"
	fi
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
	
	if [ "$arch" = x86 ] || [ "$arch" = x86_64 ]; then
		limine bios-install "$target_device"
	fi
elif [ "$1" = publish ]; then
	# make a BTRFS snapshot from the project's directory,
	# to "~/.local/spm/published/$gnunet_namespace/$pkg_name"
	
	# when hardlinking files from build dir to publish dir, skip symlinks
	
	# ".data/gnurl" stores the project's GNUnet URL: gnunet://fs/sks/<name-space>/projects/<project_name>
	# package URL is obtained from it like this: gnunet://fs/sks/<name-space>/packages/<project_name>
	
	# publish "~/.local/spm/published/$gnunet_namespace/$pkg_name" (minus the ".cache" directory) to:
	# "gnunet://fs/sks/<namespace>/packages/<package-name>/"
	
	# cross'built the package for all architectures mentioned in "$state_dir/spm.conf" (value of "arch" entry),
	# and put the results in in ".cache/spm/builds/<arch>/"
	# in "spmbuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "imp" file, plus all files in ".cache/spm/builds/<arch>/" minus "imp" directory,
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
	echo "	spm build <gnunet-namespace> <package-name>"
	echo "	spm download <gnunet-namespace> <package-name>"
	echo "	spm install <gnunet-namespace> <package-name>"
	echo "	spm remove <gnunet-namespace> <package-name>"
	echo "	spm update"
	echo "	spm publish"
	echo "	spm install-spmlinux"
fi
