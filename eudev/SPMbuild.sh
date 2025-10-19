# https://github.com/eudev-project/eudev

# skip eudev-hwids
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/eudev-hwids

# https://pkgs.alpinelinux.org/package/edge/main/x86_64/eudev-netifnames

# when creating /dev/input devices, set their group to 1
# when creating /dev/dri devices, set their group to 2
# when creating /dev/snd/* and /dev/video* devices, set their group to 1000

# to prevent BadUSB, cerate evdev rule that when a new input device is connected:
# touch /tmp/lock-bash
# chown 1000 /tmp/lock-bash
