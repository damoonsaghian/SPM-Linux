# https://git.gnunet.org/gnunet.git/tree/src

echo '[hostlist]
# Options:
# -p : provide a hostlist as a hostlist servers
# -b : bootstrap using configured hostlist servers
# -e : enable learning advertised hostlists
# -a : advertise hostlist to other servers
OPTIONS = -b -e -a -p
' > "$project_dir/.cache/spm/gnunet.conf"

# intresting fact: gnunet uses UDP to discover peers on local net

# https://docs.gnunet.org/latest/users/configuration.html#limitations-and-known-bugs
# https://docs.gnunet.org/latest/users/subsystems.html#transport-ng-next-generation-transport-management
# https://en.wikipedia.org/wiki/Long-range_Wi-Fi

# LoRa communicator for emergency communications (when normal network infrastructure is down)
# https://en.wikipedia.org/wiki/LoRa
# actually a separate LoRa device can by itself be useful in emergency situations
# 	normally it should have a rechargable battery, and a manual switch too

# for now, build libsodium and gcrypt internally, and link statically
# it will be good if GNUnet replaces them with nettle
# and even add NTRU on top, for more security (like in openssh)
