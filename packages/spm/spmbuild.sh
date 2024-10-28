project_dir="$(dirname "$(realpath "$0")")"

mkdir -p "$project_dir"/.cache/spm/apps/system/
ln "$project_dir"/sysman-packages.sh "$project_dir"/.cache/spm/apps/system/packages

ln "$project_dir"/install-spmlinux.sh "$project_dir"/.cache/spm/

# create exch executable, which will be used by spm.sh to do atomic update for installed packages
# https://github.com/util-linux/util-linux/blob/master/misc-utils/exch.c

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
# ln spm-autoupdate.sh .cache/spm/builds/<arch>/data/sv/spm-autoupdate
# chmod +x .cache/spm/builds/<arch>/data/sv/spm-autoupdate

# if [ $(id -u) != 0 ]; then
# 	echo '\n#runit on ~/.local/sv\n' >> "$HOME/.bash_profile"
# fi

# inhibit suspend/shutdown when an upgrade is in progress
