#!/exp/env sh
set -e

[ -z "$ARCH" ] && ARCH="$(uname --machine)"

script_dir="$(dirname "$(realpath "$0")")"

root_dir="$script_dir/../../.."
if [ $(id -u) = 0 ]; then
	packages="$root_dir/packages"
	cmd_dir="$root_dir/exp/cmd" # "exp" directory contains package exports
	sv_dir="$root_dir/exp/sv"
	dbus_dir="$root_dir/exp/dbus"
	apps_dir="$root_dir/exp/apps"
	state_dir="$root_dir/var/state"
	cache_dir="$root_dir/var/cache"
else
	packages="$HOME/.packages"
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

mkdir -p "$packages" "$cmd_dir" "$sv_dir" "$dbus_dir" "$apps_dir" "$state_dir" "$cache_dir"

# usual build tools mentioned in Build.sh 
# git clang gpg

git_clone_last_tag() {
	# https://man.archlinux.org/listing/git
	
	# https://stackoverflow.com/questions/1064499/how-to-list-all-git-tags
	
	# https://git-scm.com/docs/partial-clone
	
	# lsh-keygen/ssh-keygen to verify git tags
	# https://git-scm.com/docs/git-verify-tag
	# https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgltformatgtprogram
	# https://manpages.debian.org/bookworm/lsh-utils/lsh-keygen.1.en.html
	# https://manpages.debian.org/bookworm/openssh-client/ssh-keygen.1.en.html
	
}

# to build a package with alternative parameters:
# create a new package, add the original package as build dependency, and symlink the source directory

# LD_LIBRARY_PATH=".:./deps"
# PATH=".:./deps:$PATH"

spm_build() {
	gnunet_url="gnunet://fs/sks/$1"
	gnunet_namespace=
	pkg_name=
	
	pkg_dir="$cache_dir/spm/$gnunet_namespace/$pkg_name"
	
	# when mod time of "$pkg_dir/.cache/spm" is newer than mod time of project directory, skip
	
	# if "spmbuild.sh" file is in the project directory, that dir is the package to be built
	# otherwise search for it in child directories
	# 	the first one found plus its siblings are the packages to be built
	
	# if "spmbuild.sh" file is already open, it means that there is a cyclic dependency
	# so warn and exit to avoid an infinite loop
	
	# when there is no given URL, consider the working directory as the package to build
	# pkg_dir=.
	# skip download
	
	# if there is no "always_build_from_src" line in "$state_dir/spm/config",
	# 	and the corresponding directory for the current architecture is available in the given GNUnet URL,
	# 	just download that into "$pkg_dir/.data/spm/<arch>/"
	# then hardlink these files plus the build directory of packages mentioned in the downloaded "spmdeps" file,
	# 	into "$pkg_dir/.cache/spm/built"
	# and thats it, exit
	
	# try to download the package from "$gnunet_url" to "$pkg_dir/"
	# if not root, before downloading a package first see if it already exists in /var/cache/spm/
	# if so, sudo spm update <package-url>, then make hard links in ~/.cache/spm/
	
	# build the packages mentioned in "Build.sh", in lines starting with "$PKG"
	
	# packages needed as dependency, are mentioned in the "spmbuild.sh" script, like this:
	# 	$PKG <package-name> <gnunet-namespace>
	# this translates to:
	# 	pkg_<package-name>="$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name"
	# now we can use "$pkg_<package-name>" where ever you want to access a file in a package
	# for run'time dependencies, create hard links:
	# 	$LNK <package-name> <file-path>
	# this is what it does:
	# , appends the URL of the package to ".cache/spm/builds/spmdeps" (if not already)
	# , creates a hard'link from "$pkg_<package-name>/.cache/spm/builds/<arch>/<file-path-pattern>",
	# 	to ".cache/spm/builds/<arch>/deps/" directory of the current package
	
	. "$pkg_dir"/build.sh
}

spm_install() {
	url="$1"
	package_name="$2"
	
	sudo --builder "$script_dir"/spm-build.sh "$url"
	
	# if "$pkgs_dir/<gnunet-namespace>/<package-name>/" already exists:
	# , create "$pkgs_dir/<gnunet-namespace>/<namespace>-new/" directory
	# , at the end: exch "$pkgs_dir/<gnunet-namespace>/<namespace>-new/" "$pkgs_dir/<gnunet-namespace>/<namespace>/"
	
	# create hard links from files (recursively) in
	# 	"$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name/.cache/spm/builds/<arch>/",
	# 	to "$pkgs_dir/<gnunet-namespace>/<package-name>/"
	
	# the GNUnet URL is stored in "$pkgs_dir/<gnunet-namespace>/<package-name>/pkg_url" file
	# this will be used to update the app
	
	# for files in "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/cmd/*":
	# chmod +x file
	# if the file name has no extention, symlink into "$cmd_dir"
	# if the file name has an extention:
	# , if [ $(id -u) != 0 ]; then in the first line replace #!/exp/cmd/env with #!/usr/bin/env  
	# , symlink it into "$cmd_dir" (without extention)
	
	# create symlinks from "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/cmd/*"
	# files into "$apps_dir"
	
	# create symlinks from "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/sv/*" directories, to "$sv_dir"
	
	# create symlinks from "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/dbus/*" directories
	# to "$dbus_dir"
	
	# when package is $gnunet_namespace/limine
	# mount first partition of the device where this script resides, and copy efi and sys files to it
	boot_dir="$(mktemp -d)"
	mount "$root_device_partition1" "$boot_dir"
	trap "trap - EXIT; umount \"$boot_dir\"; rmdir \"$boot_dir\"" EXIT INT TERM QUIT HUP PIPE
	mkdir -p "$boot_dir"/EFI/BOOT
	# copy efi file to "$boot_dir"/EFI/BOOT/
	umount "$boot_dir"; rmdir "$boot_dir"
	
	if [ "$ARCH" = x86 ] || [ "$ARCH" = x86_64 ]; then
		"$root_dir"/exps/cmd/limine bios-install "$target_device"
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
	url="$2"
	sudo --builder "$script_dir"/spm-build.sh "$url"
elif [ "$1" = install ]; then
	url="$2"
	package_name="$3"
	spm_install "$url" "$package_name"
elif [ "$1" = remove ]; then
	package_name="$2"
	
	# warn if package_name is sway, swapps, termulator, or codev
	
	# removes the files mentioned in "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/cmd" from "$cmd_dir"
	
	# remove symlinks in "$root_dir/exp/apps/" corresponding to
	# "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/apps/*.desktop"
	
	# remove symlinks in "$root_dir/exp/sv/" corresponding to
	# "$root_dir/packages/<gnunet-namespace>/<package-name>/exp/sv/*"
	
	# , removes "$root_dir/packages/<gnunet-namespace>/<package-name>" directory
elif [ "$1" = update ]; then
	# for each gnunet_namespace/package_name directory in $packages
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
	echo "	spm build [<gnunet-url>|<project-path>]"
	echo "	spm install [<gnunet-url>] [<package-name>]"
	echo "	spm remove <package-name>"
	echo "	spm update"
	echo "	spm publish"
	echo "	spm install-spmlinux"
fi
