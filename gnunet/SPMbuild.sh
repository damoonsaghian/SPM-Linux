# https://git.gnunet.org/gnunet.git/tree/src

# https://docs.gnunet.org/latest/users/subsystems.html
# https://docs.gnunet.org/latest/users/configuration.html#access-control-for-gnunet
# https://manpages.debian.org/unstable/gnunet/gnunet.1.en.html
# https://manpages.debian.org/unstable/gnunet/index.html
# https://wiki.archlinux.org/title/GNUnet

echo '[ats]
WLAN_QUOTA_IN = unlimited
WLAN_QUOTA_OUT = unlimited
WAN_QUOTA_IN = unlimited
WAN_QUOTA_OUT = unlimited

[hostlist]
# Options:
# -p : provide a hostlist as a hostlist servers
# -b : bootstrap using configured hostlist servers
# -e : enable learning advertised hostlists
# -a : advertise hostlist to other servers
OPTIONS = -b -e -a -p
' > "$project_dir/.cache/spm/gnunet.conf"

# gn-publish.sh
# gn-download.sh

# only make system services (do not create system services for normal user)

# for database files on BTRFS, COW must be disabled
# generally it's done automatically by the program itself (eg for PostgreSQL)
# otherwise we must do it manually: chattr +C ... (eg for MariaDB databases)
# apparently Webkit uses SQLite in WAL mode, but i'm not sure about GnuNet database

# wifi ad hoc
# https://docs.gnunet.org/latest/users/configuration.html#configuring-the-wlan-transport-plugin

# for now, build libsodium and gcrypt internally, and link statically
# in the future, replace it with nettle
# and for more security add NTRU on top (like in openssh)
