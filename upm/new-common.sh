# doas rules for sd.sh

# https://github.com/eggert/tz
# only produce "right" timezones
echo '#!/bin/sh
case "$2" in
up) system tz guess ;;
esac
' > /usr/share/NetworkManager/dispatcher.d/09-dispatch-script
chmod 755 /usr/share/NetworkManager/dispatcher.d/09-dispatch-script

# autologin
echo "
# set resource limits for realtime applications like the rt module in pipewire
ulimit -r 95 -e -19 -l 4194304

# todo: implement a parent control service, which needs root password for activation and deactivation
# it runs as user "parent" (create if does not exist) and reports (through gnunet) various data
# including the status of the device (so the parent will know if the os is replaced)

exec login -f nu
" > autologin
