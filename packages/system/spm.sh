spm_dir="$HOME/.local/spm"
apps_dir="$HOME/.local/bin"
gui_apps_dir="$HOME/.local/share/applications"
sv_dir="$HOME/.local/sv"
if [ $(id -u) = 0 ]; then
	spm_dir="/spm"
	apps_dir="/apps"
	gui_apps_dir="/apps/gui"
	sv_dir="/apps/sv"
fi
# /apps/sv-sys
# /apps/dbus (dbus configs)

# if "spmbuild.sh" file is in the project directory, that is the package to be built
# otherwise search for it in child directories
# 	the first one found plus its siblings are the packages to be built

# when mod time of .cache/spm is newer than mod time of project directory, skip

# if "spmbuild.sh" file is already open, it means that there is a cyclic dependency
# so exit to avoid an infinite loop

# after linux package is installed/updated:
# mount boot partition, and copy the kernel and initramfs to it

# set suid of for doas in system package

# https://stackoverflow.com/questions/1064499/how-to-list-all-git-tags
# signing Git tags: https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work
# https://git-scm.com/docs/partial-clone

# LD_LIBRARY_PATH=".:./deps"
# PATH=".:./deps:/apps"

if [ "$1" = build ]; then
	gnunet_url="$2"
	gnunet_namespace=
	pkg_name=
	
	if [ $(id -u) = 0 ]; then
		# add a system user: spm_"$gnunet_namespace"
		adduser --system spm_"$gnunet_namespace"
		# su spm_"$gnunet_namespace"
	fi
	
	# when there is no given URL, consider the working directory as the package to build
	# pkg_path=.
	# skip download
	
	# if the value of "use_prebuilt" in "$spm_dir/config" is true,
	# 	and the corresponding directory for the current architecture is available in the given GNUnet URL,
	# 	just download that into "$spm_dir/downloads/$gnunet_namespace/$pkg_name/.data/spm/<arch>/"
	# then hardlink these files plus the build directory of packages mentioned in the downloaded "spmdeps" file,
	# 	into ".cache/spm/built"
	# check
	# and thats it, exit(0)
	
	# download the package from "$gnunet_url" to "$spm_dir/downloads/$gnunet_namespace/$pkg_name/"
	
	# after download, check the signatures in ".data/spm/sig" using the key(s) (if any) in:
	# "$spm_dir/keys/$gnunet_namespace/$pkg_name" 
	# make a hard link from ".data/spm/key" to "$spm_dir/keys/$gnunet_namespace/$pkg_name"
	
	# build the packages mentioned in "spmbuild.sh", in lines starting with "$DEP and "$BDEP"
	
	# for packages needed during the build process, do this in the "spmbuild.sh" script:
	# 	$DEP pkg_<package-name> <gnunet-url>
	# this is what it does:
	# , appends the URL to ".cache/spm/builds/spmdeps"
	# , pkg_<package-name>="$spm_dir"/downloads/$gnunet_namespace/$pkg_name
	# now we can create hard links from the needed files in "$pkg_<package-name>/.cache/spm/builds/<arch>/",
	# 	into the ".cache/spm/builds/<arch>/deps/" directory of the current package
	
	# for packages needed during the build process, do this in the "spmbuild.sh" script:
	# 	$BDEP pkg_<package-name> <gnunet-url>
	# this is what it does:
	# 	pkg_$dep_pkg_name="$spm_dir"/downloads/$dep_gnunet_namespace/$dep_pkg_name
	# now we can use "${pkg_$dep_pkg_name}" where ever you want to access a file in the needed package
	
	sh spmbuild.sh
	
	if [ $(id -un) = spm_"$gnunet_namespace" ]; then
		chown --recursive root:root "$spm_dir/downloads/$gnunet_namespace/$pkg_name/"
		deluser spm_"$gnunet_namespace"
	fi
elif [ "$1" = install ]; then
	package_name="$2"
	url="$3"
	
	spm build $url
	
	# if "$spm_dir/installed/<package-name>/" already exists, it exits with error
	
	# create hard links from files (recursively) in
	# 	"$spm_dir/downloads/$gnunet_namespace/$pkg_name/.cache/spm/builds/<arch>/",
	# 	to "$spm_dir/installed/<package-name>/"
	
	# the GNUnet URL is stored in "$spm_dir/installed/<package-name>/data/url" file
	# this will be used to update the app
	
	# create symlinks from files that their name has no extension, and are executable, into "$apps_dir"
	
	# , it'll create symlinks from "$spm_dir/installed/<package-name>/data/*.desktop" files into "$gui_apps_dir"
	# 	("$gui_apps_dir" is "/apps/gui" when "spm" is run as root, and "~/.local/share/applications" otherwise)
	
	# , it'll create symlinks from "$spm_dir/installed/<package-name>/data/sv/*" directories, to "$sv_dir"
	# 	("$sv_dir" is "/apps/sv" when "spm" is run as root, and "~/.local/sv" otherwise)
	
	# , it'll create symlinks from "/spm/installed/<package-name>/data/sv-sys/*" directories, to "/apps/sv-sys/"
	# 	actually this only happens if spm is run as root,
	# 	and only for those packages included in "trusted_packages" list in "$spm_dir/config"
	# 	(the default value of "trusted_packages" is "system gnunet")
elif [ "$1" == remove ]; then
	package_name="$2"
	
	# removes the files mentioned in "$spm_dir/installed/<package-name>/data/apps" from "$apps_dir"
	
	# remove symlinks in "$apps_dir/gui/" corresponding to "$spm_dir/installed/<package-name>/data/*.desktop"
	
	# remove symlinks in "$apps_dir/sv/" corresponding to "$spm_dir/installed/<package-name>/data/sv/*"
	
	# remove symlinks in "/apps/sv-sys/" corresponding to "/spm/installed/<package-name>/data/sv-sys/*"
	# 	(if run as root, and the package is in "trusted_packages" list)
	
	# , removes "$spm_dir/installed/<package-name>" directory
elif [ "$1" == update ]; then
	# directories in $spm_dir/installed/
	# see if "$spm_dir/installed/<package-nam>/url" file exists
	# download
	# if third line exists, it's a public key; use it to check the signature (in ".data/sig")
	# run spm install for each one
	
	# check in each update, if the ref count if files in .cache/spm/builds is 1, clean that package
	# file_ref_count=$(stat -c %h filename)
	
	# fwupd
	# boot'firmware updates need special care
	# unless there is a read'only backup, firmware update is not a good idea
	# so warn and ask the user if she wants the update
elif [ "$1" == publish ]; then
	# make a BTRFS snapshot from the project's directory,
	# to "~/.local/spm/published/$gnunet_namespace/$pkg_name"
	
	# ".data/gnurl" stores the project's GNUnet URL: gnunet://<name-space>/projects/<project_name>
	# package URL is obtained from it like this: gnunet://<name-space>/packages/<project_name>
	
	# cross'built the package for all architectures mentioned in "$spm_dir/config" (value of "arch" entry),
	# and put the results in in ".cache/spm/builds/<arch>/"
	# in "spmbuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "spmdeps" file, plus all files in ".cache/spm/builds/<arch>/" minus "deps" directory,
	# and put them in ".data/spm/<arch>/"
	
	# publish "~/.local/spm/published/$gnunet_namespace/$pkg_name" (minus the ".cache" directory) to:
	# "gnunet://<namespace>/packages/<package-name>/"
	
	# the "spmbuild.sh" file will be published into the GNUnet namespace
	# the source files can be in the same place, or in a Git URL
	# 	in which case, there must be a "git clone <git-url> .cache/git" line, in the "spmbuild.sh" file
else
	# show usage guide
	# spm build [<gnunet-url>|<project-path>]
	# spm install <package-name> <gnunet-url>
	# spm remove <package-name>
	# spm update
	# spm publish
fi
