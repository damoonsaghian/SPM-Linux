project_dir="$(dirname "$0")"

mkdir -p "$project_dir"/.cache/spm/exp/cmd
ln "$project_dir"/spm.sh > "$project_dir"/.cache/spm/exp/cmd/spm

ln "$project_dir"/install.sh "$project_dir"/.cache/spm/

# create exch executable, which will be used by spm.sh to do atomic update for installed packages
# https://github.com/util-linux/util-linux/blob/master/misc-utils/exch.c

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
# ln spm-autoupdate.sh .cache/spm/builds/<arch>/data/sv/spm-autoupdate
# chmod +x .cache/spm/builds/<arch>/data/sv/spm-autoupdate

# sudo rules for "spm install-spmlinux" and "spm download"

# inhibit suspend/shutdown when an upgrade is in progress
