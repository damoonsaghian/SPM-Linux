src_dir="$1"
gnunet_namespace="$2"
publish_name="$3"

# https://www.gnunet.org/en/use.html
# https://wiki.archlinux.org/title/GNUnet
# https://manpages.debian.org/unstable/gnunet/
# https://git.gnunet.org/gnunet.git/tree/src

# "$project_dir/.data/gnunet" file contains these lines:
# , project name
# , the level of anonymity
# , public key of egos used for publishing (namespaces)
# if this file exists use it, try to copy from a siblibg project "$project_dir/../*/.data/gnunet",
# 	otherwise ask the user, and create one
# other than the main ego, create at least two alternative egos

# ask for password
# decrypt and namespace mount the egos dir on itself
# gnunet-publish
# https://wiki.archlinux.org/title/ECryptfs
# https://github.com/oszika/ecryptbtrfs

# create ref links (or read'only hard links) of the files in $project_dir/.data/gnunet/publish
# this way GNUnet can publish the files using the indexed method

# when ref/hard linking files to publish dir, skip symlinks

# skip .cache directory

# gnunet-search gnunet://fs/sks/$gnunet_namespace/$publish_name
# find the latest version, then compute the next version
sks_identifier=
sks_next_identifier=

# when a publish is in progress, and for minutes after that, inhibit suspend
# also when a shutdown is requested, notice the user, and ask to confirm
