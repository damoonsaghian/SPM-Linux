project_dir="$(dirname "$0")"

# https://github.com/git/git/blob/master/INSTALL
# https://github.com/git/git/blob/master/Makefile
# configure git to use lsh instead of openssh:
# 	https://github.com/git/git/blob/master/Documentation/config/ssh.txt
spm_build lsh
