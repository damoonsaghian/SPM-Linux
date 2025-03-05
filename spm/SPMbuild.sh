mkdir -p "$build_dir"/exec
ln "$pkg_dir/spm.sh" "$build_dir/exec/spm"
chmod +x "$build_dir/exec/spm"
spm_xcript spm inst/cmd
ln "$pkg_dir/install.sh" "$build_dir/exec/spm-install"
chmod +x "$build_dir/exec/spm-install"
spm_xcript spm-install inst/cmd

# create exch executable, which will be used by spm.sh to do atomic update for installed packages
# https://github.com/util-linux/util-linux/blob/master/misc-utils/exch.c

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
# ln spm-autoupdate.sh .cache/spm/builds/<arch>/data/sv/spm-autoupdate
# chmod +x .cache/spm/builds/<arch>/data/sv/spm-autoupdate

# sudo rules for "spm install-spmlinux" and "spm download"

# inhibit suspend/shutdown when an upgrade is in progress
