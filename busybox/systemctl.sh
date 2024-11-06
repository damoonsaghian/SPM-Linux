#!/apps/doas /apps/sh

case "$1" in
suspend) echo mem > /sys/power/state ;;
reboot) reboot ;;
poweroff) poweroff ;;
esac
