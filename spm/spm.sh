set -e

script_dir="$(dirname "$(realpath "$0")")"

gnunet_namespace=

spm_dir="$script_dir/../../../.."
if [ $(id -u) = 0 ] && [ -z "$EXAS" ]; then
	cmd_dir="$spm_dir/exps/cmd"
	sv_dir="$spm_dir/exps/sv"
	dbus_dir="$spm_dir/exps/dbus"
	state_dir="$spm_dir/var/state"
	cache_dir="$spm_dir/var/cache"
elif [ $(id -u) = 0 ] && [ -n "$EXAS" ]; then
	cmd_dir="$spm_dir/exp/cmd"
	sv_dir="$spm_dir/exp/sv"
	dbus_dir="$spm_dir/exp/dbus"
	apps_dir="$spm_dir/exp/applications"
	state_dir="$spm_dir/var/state"
	cache_dir="$spm_dir/var/cache"
else
	cmd_dir="$HOME/.local/bin"
	sv_dir="$HOME/.spm/exp/sv"
	dbus_dir="$HOME/.spm/exp/dbus"
	apps_dir="$HOME/.local/share/applications"
	state_dir="$XDG_STATE_HOME"
	[ -z "$state_dir" ] &&
		state_dir="$HOME/.local/state"
	cache_dir="$XDG_CACHE_HOME"
	[ -z "$cache_dir" ] &&
		cache_dir="$HOME/.cache"
fi
mkdir -p "$cmd_dir" "$apps_dir" "$sv_dir" "$dbus_dir"

# https://stackoverflow.com/questions/1064499/how-to-list-all-git-tags
# signing Git tags: https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work
# lsh-keygen/ssh-keygen to verify and sign tags
# 	only git tags signed using ssh keys are supported (gpg is not supported)
# 	https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgltformatgtprogram
# 	https://manpages.debian.org/bookworm/openssh-client/ssh-keygen.1.en.html
# https://git-scm.com/docs/partial-clone

# to build a package with alternative parameters:
# create a new package, add the original package as build dependency, and symlink the source directory

# LD_LIBRARY_PATH=".:./deps"
# PATH=".:./deps:$PATH"

if [ "$1" = build ]; then
	gnunet_url="$2"
	arch="$3"
	gnunet_namespace=
	pkg_name=
	
	# when mod time of .cache/spm is newer than mod time of project directory, skip
	
	# if "spmbuild.sh" file is in the project directory, that is the package to be built
	# otherwise search for it in child directories
	# 	the first one found plus its siblings are the packages to be built
	
	# if "spmbuild.sh" file is already open, it means that there is a cyclic dependency
	# so exit to avoid an infinite loop
	
	# when there is no given URL, consider the working directory as the package to build
	# pkg_path=.
	# skip download
	
	# if there is no "always_build_from_src" line in "$state_dir/spm/config",
	# 	and the corresponding directory for the current architecture is available in the given GNUnet URL,
	# 	just download that into "$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name/.data/spm/<arch>/"
	# then hardlink these files plus the build directory of packages mentioned in the downloaded "spmdeps" file,
	# 	into ".cache/spm/built"
	# check the signature
	# and thats it, exit
	
	# try to download the package from "$gnunet_url" to "$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name/"
	
	# after download, check the signatures in ".data/spm/sig" using the key(s) (if any) in:
	# "$pkgs_dir/keys/$gnunet_namespace/$pkg_name" 
	# make a hard link from ".data/spm/key" to "$pkgs_dir/keys/$gnunet_namespace/$pkg_name"
	
	# build the packages mentioned in "spmbuild.sh", in lines starting with "$PKG"
	
	# packages needed as dependency, are mentioned in the "spmbuild.sh" script, like this:
	# 	$PKG <package-name> <gnunet-namespace>
	# this translates to:
	# 	pkg_<package-name>="$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name"
	# now we can use "${pkg_$pkg_name}" where ever you want to access a file in a package
	# for run'time dependencies, create hard links:
	# 	$LNK <package-name> <file-path>
	# this is what it does:
	# , appends the URL of the package to ".cache/spm/builds/spmdeps" (if not already)
	# , creates a hard'link from "$pkg_<package-name>/.cache/spm/builds/<arch>/<file-path-pattern>",
	# 	to ".cache/spm/builds/<arch>/deps/" directory of the current package
	
	if [ $(id -u) = 0 ] && [ is_a_sys_package != true ] ; then
		adduser --system spm_"$gnunet_namespace-$pkg_name"
		su -c "sh spmbuild.sh \"$arch\"" spm_"$gnunet_namespace-$pkg_name"
	else
		sh spmbuild.sh $arch
	fi
elif [ "$1" = install ]; then
	package_name="$2"
	url="$3"
	
	spm build $url
	
	# if "$pkgs_dir/<gnunet-namespace>/<package-name>/" already exists:
	# , create "$pkgs_dir/<gnunet-namespace>/<namespace>-new/" directory
	# , at the end: exch "$pkgs_dir/<gnunet-namespace>/<namespace>-new/" "$pkgs_dir/<gnunet-namespace>/<namespace>/"
	
	# create hard links from files (recursively) in
	# 	"$cache_dir/spm/downloads/$gnunet_namespace/$pkg_name/.cache/spm/builds/<arch>/",
	# 	to "$pkgs_dir/<gnunet-namespace>/<package-name>/"
	
	# the GNUnet URL is stored in "$pkgs_dir/<gnunet-namespace>/<package-name>/pkg_url" file
	# this will be used to update the app
	
	# for files in "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/cmd/*":
	# chmod +x file
	# if the file name has no extention, symlink into "$cmd_dir"
	# if the file name has an extention:
	# , if [ $(id -u) != 0 ]; then in the first line replace #!/exp/cmd/env with #!/usr/bin/env  
	# , symlink it into "$cmd_dir" (without extention)
	
	# create symlinks from "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/cmd/*"
	# files into "$apps_dir"
	
	# create symlinks from "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/sv/*" directories, to "$sv_dir"
	
	# create symlinks from "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/dbus/*" directories
	# to "$dbus_dir"
	
	# when package is $gnunet_namespace/limine
	# mount first partition of the device where this script resides, and copy efi and sys files to it
	boot_dir="$(mktemp -d)"
	mount "$root_device_partition1" "$boot_dir"
	trap "trap - EXIT; umount \"$boot_dir\"; rmdir \"$boot_dir\"" EXIT INT TERM QUIT HUP PIPE
	mkdir -p "$boot_dir"/EFI/BOOT
	# copy efi file to "$boot_dir"/EFI/BOOT/
	umount "$boot_dir"; rmdir "$boot_dir"
	
	# when package is $gnunet_namespace/linux
	# mount first partition of the device where this script resides, and copy the kernel and initramfs to it
	# umount
elif [ "$1" = remove ]; then
	package_name="$2"
	
	# removes the files mentioned in "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/cmd" from "$cmd_dir"
	
	# remove symlinks in "$spm_dir/exp/apps/" corresponding to
	# "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/apps/*.desktop"
	
	# remove symlinks in "$spm_dir/exp/sv/" corresponding to
	# "$spm_dir/packages/<gnunet-namespace>/<package-name>/exp/sv/*"
	
	# , removes "$spm_dir/packages/<gnunet-namespace>/<package-name>" directory
elif [ "$1" = update ]; then
	# directories in $pkgs_dir
	# see if "$pkgs_dir/<gnunet-namespace>/<package-nam>/url" file exists
	# download
	# if third line exists, it's a public key; use it to check the signature (in ".data/sig")
	# run spm install for each one
	
	# check in each update, if the ref count if files in .cache/spm/builds is 1, clean that package
	# file_ref_count=$(stat -c %h filename)
	
	# when the namespace directory is empty, delete it, then:
	# deluser spm_"$gnunet_namespace"
	
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
	
	# cross'built the package for all architectures mentioned in "$script_dir/spm.conf" (value of "arch" entry),
	# and put the results in in ".cache/spm/builds/<arch>/"
	# in "spmbuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "spmdeps" file, plus all files in ".cache/spm/builds/<arch>/" minus "deps" directory,
	# and put them in ".cache/spm/builds-published/<arch>/"
	
	# gnunet-unindex the old published files
	
	# publish "~/.local/spm/published/$gnunet_namespace/$pkg_name" (minus the ".cache" directory) to:
	# "gnunet://fs/sks/<namespace>/packages/<package-name>/"
	
	# publish ".cache/spm/builds-published/<arch>/" to:
	# "gnunet://fs/sks/<namespace>/package_builds/<package-name>/<arch>"
	
	# the "spmbuild.sh" file will be published into the GNUnet namespace
	# the source files can be in the same place, or in a Git URL
	# 	in which case, there must be a "git clone <git-url> .cache/git" line, in the "spmbuild.sh" file
elif [ "$1" = spmlinux ]; then
	. "$(dirname "$0")"/spmlinux.sh
else
	# show usage guide
	# spm build [<gnunet-url>|<project-path>]
	# spm install <package-name> <gnunet-url>
	# spm remove <package-name>
	# spm update
	# spm publish
fi
