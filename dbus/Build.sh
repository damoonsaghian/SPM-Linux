project_dir="$(dirname "$0")"

# https://man.archlinux.org/listing/dbus

# sv/dbus

# in system.conf:
# <includedir>/exp/dbus</includedir>
# <servicedir>/exp/dbus/services</servicedir>
# in session.conf:
# <includedir>$HOME/.spm/exp/dbus</includedir>
# <servicedir>$HOME/.spm/exp/dbus/services</servicedir>

# $dbus_dir/session.conf
# $dbus_dir/session.d/
# $dbus_dir/services/

# https://github.com/chimera-linux/dbus-wait-for
# https://git.sr.ht/~whynothugo/dbus-waiter
