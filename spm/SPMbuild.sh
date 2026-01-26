spm_import git
spm_import ssh # needed for "ssh-keygen"
spm_import codev-utils
spm_import codev-shell # for "sd"

mkdir -p "$build_dir"/exec
ln "$pkg_dir/spm.sh" "$build_dir/exec/spm"
chmod +x "$build_dir/exec/spm"
spm_xcript spm inst/cmd
ln "$pkg_dir/spm-new.sh" "$build_dir/exec/spm-new"
chmod +x "$build_dir/exec/spm-install"
spm_xcript spm-new inst/cmd

# doas rules for "spm new" and "spm update"

# autoupdate
# service timer: 5min after boot, every 24h
