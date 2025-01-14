project_dir="$(dirname "$0")"

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

# inhibit suspend/shutdown when a publish is in progress

# gnunet-publish.sh
# , ask for password
# , decrypt and namespace mount the egos dir on itself
# , gnunet-publish
# https://wiki.archlinux.org/title/ECryptfs
# https://github.com/oszika/ecryptbtrfs

# for database files on BTRFS, COW must be disabled
# generally it's done automatically by the program itself (eg for PostgreSQL)
# otherwise we must do it manually: chattr +C ... (eg for MariaDB databases)
# apparently Webkit uses SQLite in WAL mode, but i'm not sure about GnuNet

# for now internally build gnutls and gcrypt
# in the future replace them with openssl
