project_dir="$(dirname "$0")"

# https://docs.voidlinux.org/

# https://wiki.artixlinux.org/Main/Installation
# https://gitea.artixlinux.org/artix
# https://packages.artixlinux.org/

# https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html
# https://gitlab.alpinelinux.org/alpine
# https://gitlab.alpinelinux.org/alpine/alpine-conf
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/alpine-base

# https://github.com/glasnostlinux/glasnost
# https://www.linuxfromscratch.org/ https://www.linuxfromscratch.org/lfs/view/stable/
# https://github.com/iglunix
# https://github.com/gobolinux
# https://github.com/oasislinux/oasis
# https://sta.li/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html

# https://smarden.org/runit/
# https://man.voidlinux.org/runsvdir.8
# https://git.alpinelinux.org/aports/tree/main/openrc

# all services even are one'shot ones are started supervised
# one'shot services will stop the superviser at the end
# for dependencies use run'levels

# init
# run services
# mount a tmpfs in /run and /tmp

mkdir -p "$project_dir"/.cache/spm/bin
echo '#!/usr/bin/doas /usr/bin/sh
case "$1" in
suspend) echo mem > /sys/power/state ;;
reboot) reboot ;;
poweroff) poweroff ;;
esac
' > "$project_dir"/.cache/spm/bin/system
# doas rule, for users in sudo group
