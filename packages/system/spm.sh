spm_dir="$HOME/.local/spm"
apps_dir="$HOME/.local/bin"
gui_apps_dir="$HOME/.local/share/applications"
sv_dir="$HOME/.local/sv"
run=sh

if [ $(id -u) = 0 ]; then
	spm_dir="/spm"
	apps_dir="/apps"
	gui_apps_dir="/apps/gui"
	sv_dir="/apps/sv"
	
	run=unshare
	# "https://en.wikipedia.org/wiki/Linux_namespaces"
	# "https://git.busybox.net/busybox/tree/util-linux/unshare.c"
	# "https://manpages.debian.org/bookworm/util-linux/unshare.1.en.html"
	# "https://github.com/containers/bubblewrap"
	# disable the ability to set suid
fi

# if "spmbuild.sh" file is already open, it means that there is a cyclic dependency
# so exit to avoid an infinite loop

# after linux package is installed/updated:
# mount boot partition, and copy the kernel and initramfs to it

# set suid of for doas in system package

# /apps/gui
# /apps/sv
# /apps/sv-sys
# /apps/dbus (dbus configs)

# https://stackoverflow.com/questions/1064499/how-to-list-all-git-tags
# signing Git tags: https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work
# https://git-scm.com/docs/partial-clone

# if during auto update an error occures:
# ; echo error > $spm_dir/status

# LD_LIBRARY_PATH=".:./deps"
# PATH=".:./deps:/apps"

# when mod time of .cache/spm is newer than mod time of project directory, skip

# if "spmbuild.sh" file is in the project directory, that is the package to be built
# otherwise search for it in child directories
# 	the first one found plus its siblings are the packages to be built

build() {
	url="$1"
	
	url_hash="$(echo -n "$url" | md5sum | cut -d ' ' -f1)"
	
	# download the package from the given GNUnet URL to "$spm_dir/downloads/<url-hash>"
	# ("$spm_dir" is "/spm" when "spm" is run as root, and "~/.local/spm" otherwise)
	# $run gnunet
	
	# if the value of "use_prebuilt" in "$spm_dir/config" is true,
	# 	and the corresponding directory for the current architecture is available in the given GNUnet URL,
	# 	just download that into ".data/spm/<arch>/"
	# then hardlink these files plus the build directory of packages mentioned in "spmdeps",
	# 	into ".cache/spm/built", and skip running "spmbuild.sh"
	
	# after download, check the signatures in ".data/spm/sig" using the key(s) (if any) in:
	# "$spm_dir/keys/<url-hash>" 
	# make a hard link from ".data/spm/key" to "$spm_dir/keys/<url-hash>"
	
	# when there is no given URL, consider the working directory as the package to build
	
	# build the packages mentioned in "spmbuild.sh", in lines starting with "$DEP" and "$BDEP"
	
	# $DEP 
	# , create hard links from the files in "$spm_dir/downloads/<url-hash>/.cache/spm/builds/<arch>/" (recursively),
	# 	into the ".cache/spm/builds/<arch>/deps/" directory of the current package
	# , append the URL to ".cache/spm/builds/spmdeps"
	
	# for packages needed during the build process, do this in the "spmbuild.sh" script:
	# 	$BTD pkg_<package-name> <gnunet-url>
	# then use "$pkg_<package-name>" where ever you want to access a file in the needed package
	# before running spmbuild.sh, $BTD packages will be built
	# this is what $BTD does:
	# 	pkg_<package-name>="$spm_dir"/downloads/<url-hash-needed-package>
	
	$run "spmbuild.sh"
}

install() {
	package_name="$1"
	url="$2"
	
	build $url
	
	# if "$spm_dir/installed/<package-name>/" already exists, it exits with error
	
	# create hard links from files (recursively) in "$spm_dir/downloads/<url-hash>/.cache/spm/builds/<arch>/",
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
}

remove() {
	# removes the files mentioned in "$spm_dir/installed/<package-name>/data/apps" from "$apps_dir"
	
	# , removes symlinks in "$apps_dir/gui/" corresponding to "$spm_dir/installed/<package-name>/data/*.desktop"
	
	# , removes symlinks in "$apps_dir/sv/" corresponding to "$spm_dir/installed/<package-name>/data/sv/*"
	
	# , removes symlinks in "/apps/sv-sys/" corresponding to "/spm/installed/<package-name>/data/sv-sys/*"
	# 	(if run as root, and the package is in "trusted_packages" list)
	
	# , removes "$spm_dir/installed/<package-name>" directory
}

publish() {
	# make a BTRFS snapshot from the project's directory,
	# to "~/.local/spm/published/<url-hash>"
	
	# ".data/gnurl" stores the project's GNUnet URL: gnunet://<name-space>/projects/<project_name>
	# package URL is obtained from it like this: gnunet://<name-space>/packages/<project_name>
	
	# cross'built the package for all architectures mentioned in "$spm_dir/config" (value of "arch" entry),
	# and put the results in in ".cache/spm/builds/<arch>/"
	# in "spmbuild.sh" scripts we can use "$carch" variable when cross'building
	# "$carch" is an empty string when not cross'building
	
	# make hard links from "spmdeps" file, plus all files in ".cache/spm/builds/<arch>/" minus "deps" directory,
	# and put them in ".data/spm/<arch>/"
	
	# publish "~/.local/spm/published/<url-hash>" (minus the ".cache" directory) to:
	# "gnunet://<namespace>/packages/<package-name>/"
	
	# the "spmbuild.sh" file will be published into the GNUnet namespace
	# the source files can be in the same place, or in a Git URL
	# 	in which case, there must be a "git clone <git-url> .cache/git" line, in the "spmbuild.sh" file
}

if [ "$1" = install ]; then
	install $2 $3
elif [ "$1" == remove ]; then
	remove $2
elif [ "$1" == update ]; then
	# directories in $spm_dir/installed/
	# see if "$spm_dir/installed/<package-nam>/url" file exists
	# download
	# if third line exists, it's a public key; use it to check the signature (in ".data/sig")
	# run install.sh in each one
	# check in each update, if the number of hard links to files in .cache/spm/app is 2, clean that package
	# number_of_links=$(stat -c %h filename)
elif [ "$1" == autoupdate ]; then
	# https://www.freedesktop.org/wiki/Software/systemd/inhibit/
	
	metered_connection() {
		local active_net_device="$(ip route show default | head -1 | sed -n "s/.* dev \([^\ ]*\) .*/\1/p")"
		local is_metered=false
		case "$active_net_device" in
			ww*) is_metered=true ;;
		esac
		# todo: DHCP option 43 ANDROID_METERED
		$is_metered
	}
	metered_connection && exit 0
else
	# show usage guide
	# spm build [<gnunet-url>|<project-path>]
	# spm install <package-name> <gnunet-url>
	# spm remove <package-name>
	# spm publish

fi

# do some cleaning
