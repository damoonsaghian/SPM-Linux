project_dir="$(dirname "$0")"

# https://man.archlinux.org/listing/dbus

# sv/dbus

# in system.conf:
# <includedir>/apps/dbus</includedir>
# <servicedir>/apps/dbus/services</servicedir>
# in session.conf:
# <includedir>/home/.spm/apps/dbus</includedir>
# <servicedir>/home/.spm/apps/dbus/services</servicedir>

# $dbus_dir/session.conf
# $dbus_dir/session.d/
# $dbus_dir/services/

# https://github.com/chimera-linux/dbus-wait-for
# https://git.sr.ht/~whynothugo/dbus-waiter
