project_dir="$(dirname "$0")"

# https://pkgs.alpinelinux.org/package/edge/main/x86_64/util-linux
# https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/
# disable: su runuser login flock logger partx setarch cfdisk

ln "$project_dir"/login.sh "$project_dir"/.cache/spm/exp/cmd/login

# agetty service for each terminal
# /usr/bin/agetty --skip-login --login-program /exp/cmd/login %I $TERM

# doas rule for rfkill
