project_dir="$(dirname "$(realpath "$0")")"

# https://gitlab.freedesktop.org/NetworkManager/NetworkManager
# https://networkmanager.dev/docs/
# https://wiki.archlinux.org/index.php/NetworkManager

# networkmanager without polkit, and with gnutls (instead of nss)
# https://www.linuxfromscratch.org/blfs/view/stable/basicnet/networkmanager.html

# iwd
# iwd service
# doas rule

# modemmanager without polkit
# https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/blob/main/data/org.freedesktop.ModemManager1.conf.polkit
# https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/blob/main/data/org.freedesktop.ModemManager1.policy.in.in
# https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/community/modemmanager/modemmanager.rules
# https://modemmanager.org/docs/
# modemmanager service

# in a networkmanager dispatcher set the timezone
# https://www.freedesktop.org/software/ModemManager/api/latest/gdbus-org.freedesktop.ModemManager1.Modem.Time.html
# tz set "$offset"

# RP-PPPoE

# vpn plugins

# making bridges (eg for tethering or creating a router)
# https://wiki.debian.org/NetworkConfiguration
# https://wiki.alpinelinux.org/wiki/Configure_Networking
# https://wiki.alpinelinux.org/wiki/Bridge#Using_pre-up/post-down
# https://wiki.alpinelinux.org/wiki/How_to_setup_a_wireless_access_point

mkdir -p "$project_dir"/.cache/spm/apps/system
ln "$project_dir"/sysman-connections.sh "$project_dir"/.cache/spm/apps/system/connections

echo '#!/bin/sh
# update system timezone
' > /etc/NetworkManager/dispatcher.d/09-dispatch-script
chmod 755 /etc/NetworkManager/dispatcher.d/09-dispatch-script
