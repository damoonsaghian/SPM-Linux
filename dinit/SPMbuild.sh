# https://github.com/davmac314/dinit

# init
# run services
# mount a tmpfs in /run and /tmp
# PATH=/usr/bin

mkdir -p "$project_dir"/.cache/spm/bin
echo '#!/usr/bin/sudo /usr/bin/sh
case "$1" in
suspend) echo mem > /sys/power/state ;;
reboot) reboot ;;
poweroff) poweroff ;;
esac
' > "$project_dir"/.cache/spm/bin/system
# sudo rule

# https://docs.voidlinux.org/config/power-management.html
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/acpid
