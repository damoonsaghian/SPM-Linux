src_dir="$1"
gnunet_namespace="$2"
publish_name="$3"

# https://www.gnunet.org/en/use.html
# https://wiki.archlinux.org/title/GNUnet
# https://manpages.debian.org/unstable/gnunet/
# https://git.gnunet.org/gnunet.git/tree/src

# "$project_dir/../.gnunet" file: associated ego for publishing, plus the level of anonymity
# if this file exists use it, otherwise ask the user to create an ego

# ask for password
# decrypt and namespace mount the egos dir on itself
# gnunet-publish
# https://wiki.archlinux.org/title/ECryptfs
# https://github.com/oszika/ecryptbtrfs

# create ref links (or read'only hard links) of the files in $project_dir/.data/gnunet/publich
# this way GNUnet can publish the files using the indexed method

# gnunet-search gnunet://fs/sks/$gnunet_namespace/$publish_name
# find the latest version, then compute the next version
sks_identifier=
sks_next_identifier=

# when a publish is in progress, and for minutes after that, inhibit suspend
# also when a shutdown is requested, notice the user, and ask to confirm

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
