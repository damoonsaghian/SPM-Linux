upm_import git
upm_import ssh # needed for "ssh-keygen"

mkdir -p "$build_dir"/exec
ln "$pkg_dir/upm.sh" "$build_dir/exec/upm"
chmod +x "$build_dir/exec/upm"
upm_xcript upm inst/cmd

# doas rules for "upm"

# autoupdate crond file

# mkinst.sh install.sh mkfs.sh
