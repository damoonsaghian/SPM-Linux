set -e

script_dir="$(dirname "$(realpath "$0")")"

gnunet_namespace=

if [ $(id -u) = 0 ]; then
	pkgs_dir="$script_dir/../../.."
	apps_dir="$pkgs_dir/../usr/bin"
	apps_gui_dir="$pkgs_dir/../usr/share/applications"
	sv_dir="$pkgs_dir/../usr/share/sv"
	dbus_dir="$apps_dir/../usr/share/dbus-1"
	config_dir=
else
	pkgs_dir="$HOME/.spm-packages"
	apps_dir="$HOME/.local/bin"
	apps_gui_dir="$HOME/.local/share/applications"
	sv_dir="$HOME/.local/share/sv"
	dbus_dir="$HOME/.local/share/dbus-1"
	config_dir=
fi
mkdir -p "$apps_dir" "$sv_dir" "$dbus_dir"

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
# PATH=".:./deps:/apps-sys:/apps"

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
	
	# if there is no "always_build_from_src" line in "$config_dir/spm/config",
	# 	and the corresponding directory for the current architecture is available in the given GNUnet URL,
	# 	just download that into "$pkgs_dir/downloads/$gnunet_namespace/$pkg_name/.data/spm/<arch>/"
	# then hardlink these files plus the build directory of packages mentioned in the downloaded "spmdeps" file,
	# 	into ".cache/spm/built"
	# check the signature
	# and thats it, exit
	
	# try to download the package from "$gnunet_url" to "$pkgs_dir/downloads/$gnunet_namespace/$pkg_name/"
	
	# after download, check the signatures in ".data/spm/sig" using the key(s) (if any) in:
	# "$pkgs_dir/keys/$gnunet_namespace/$pkg_name" 
	# make a hard link from ".data/spm/key" to "$pkgs_dir/keys/$gnunet_namespace/$pkg_name"
	
	# build the packages mentioned in "spmbuild.sh", in lines starting with "$PKG"
	
	# packages needed as dependency, are mentioned in the "spmbuild.sh" script, like this:
	# 	$PKG <package-name> <gnunet-namespace>
	# this translates to:
	# 	pkg_<package-name>="$pkgs_dir"/downloads/$gnunet_namespace/$pkg_name
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
	
	# if package_name is system or linux, but the namespace (public key) does not match, exit with error
	
	# if "$pkgs_dir/installed/<package-name>/" already exists:
	# , create "$pkgs_dir/installed/<namespace>-new/" directory
	# , at the end: exch "$pkgs_dir/installed/<namespace>-new/" "$pkgs_dir/installed/<namespace>/"
	
	# create hard links from files (recursively) in
	# 	"$pkgs_dir/downloads/$gnunet_namespace/$pkg_name/.cache/spm/builds/<arch>/",
	# 	to "$pkgs_dir/installed/<package-name>/"
	
	# the GNUnet URL is stored in "$pkgs_dir/installed/<package-name>/pkg_url" file
	# this will be used to update the app
	
	# for files in "$pkgs_dir/installed/<package-name>/apps/*":
	# chmod +x file
	# if the file name has no extention, symlink into "$apps_dir"
	# if the file name has an extention:
	# , if [ $(id -u) != 0 ]; then in the first line replace #!/apps/env with #!/usr/bin/env  
	# , symlink it into "$apps_dir" (without extention)
	
	# if $is_a_sys_packages, for files in "$pkgs_dir/installed/<package-name>/apps-sys/*":
	# chmod +x file
	# if the file name has no extention, symlink it into "$apps_sys_dir"
	# if the file name has .suid extension, set SUID bit, and symlink it into "$apps_sys_dir" (without extention)
	# if they have other extentions:
	# , if [ $(id -u) != 0 ]; then in the first line replace #!/apps/env with #!/usr/bin/env  
	# , symlink it into "$apps_sys_dir" (without extention)
	
	# create symlinks from "$pkgs_dir/installed/<package-name>/apps/gui/*" files into "$HOME/.local/share/applications"
	
	if [ $(id -u) != 0 ]; then
		mkdir -p "$apps_dir/settings"
		ln "$pkgs_dir/installed/<package-name>/apps/settings/*" "$apps_dir/settings/"
	fi
	
	# create symlinks from "$pkgs_dir/installed/<package-name>/apps/sv/*" directories, to "$sv_dir"
	# if $is_a_sys_package:
	# create symlinks from "$pkgs_dir/installed/<package-name>/apps-sys/sv/*" directories, to "$sv_sys_dir"
	
	# create symlinks from "$pkgs_dir/installed/<package-name>/apps/dbus/*" directories, to "$dbus_dir"
	# if $is_a_sys_package:
	# create symlinks from "$pkgs_dir/installed/<package-name>/apps-sys/dbus/*" directories, to "$dbus_sys_dir"
	
	# $dbus_dir/session.conf
	# $dbus_dir/session.d/
	# $dbus_dir/services/
	# $dbus_sys_dir for sys packages
	
	# then create a symlink in $pkgs_dir/installed/<pkg-name>/config/
	
	# when package is $gnunet_namespace/limine
	# mount first partition of the device where this script resides, and copy efi and sys files to it
	# mkdir /boot
	# mount "$root_device_partition1" /boot
	# mkdir -p /boot/EFI/BOOT
	# umount
	
	# when package is $gnunet_namespace/linux
	# mount first partition of the device where this script resides, and copy the kernel and initramfs to it
	# umount
elif [ "$1" = remove ]; then
	package_name="$2"
	
	# removes the files mentioned in "$pkgs_dir/installed/<package-name>/data/apps" from "$apps_dir"
	
	# remove symlinks in "$apps_dir/gui/" corresponding to "$pkgs_dir/installed/<package-name>/data/*.desktop"
	
	# remove symlinks in "$apps_dir/sv/" corresponding to "$pkgs_dir/installed/<package-name>/data/sv/*"
	
	# remove symlinks in "/apps/sv-sys/" corresponding to "/spm/installed/<package-name>/data/sv-sys/*"
	# (if package is in "$sys_packages")
	
	# remove the files that are symlinked in $pkgs_dir/installed/<pkg-name>/config/
	
	# , removes "$pkgs_dir/installed/<package-name>" directory
elif [ "$1" = update ]; then
	# directories in $pkgs_dir/installed/
	# see if "$pkgs_dir/installed/<package-nam>/url" file exists
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
