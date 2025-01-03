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

# https://en.wikipedia.org/wiki/Wireless_mesh_network
# https://en.wikipedia.org/wiki/WiGig

# decentralized time synchronization using DHT

# gnunet-publish.sh
# , ask for password
# , decrypt and namespace mount the egos dir on itself
# , gnunet-publish
# https://wiki.archlinux.org/title/ECryptfs
# https://github.com/oszika/ecryptbtrfs
