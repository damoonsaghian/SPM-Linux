# ifupdown
# allow-hotplug
# ethernet devices
# wifi devices
# ATM and WWAN devices (use ppp linke in netctl)
# https://manpages.debian.org/bullseye/ifupdown/interfaces.5.en.html

# use ifplugd to "ip link up/down" when an interface is pluged in/out
# wifi pre-up: if there is a link and ethernet is unplugged
# WWAN pre-up: if ethernet and wifi are unplugged
# https://git.busybox.net/busybox/tree/networking/ifplugd.c

# making bridges (eg for tethering or creating a router)
# https://wiki.debian.org/NetworkConfiguration
# https://wiki.alpinelinux.org/wiki/Configure_Networking
# https://wiki.alpinelinux.org/wiki/Bridge#Using_pre-up/post-down
# https://wiki.alpinelinux.org/wiki/How_to_setup_a_wireless_access_point

# https://wiki.alpinelinux.org/wiki/Wi-Fi
