# dash (as "sh" command to run system scripts)
# https://git.kernel.org/pub/scm/utils/dash/dash.git/tree/

# zsh (for interactive shell)
# https://sourceforge.net/p/zsh/code/ci/master/tree/
printf '
PS1="\e[7m \u@\h \e[0m \e[7m \w \e[0m\n> "
' > "$spm_share"/zsh/.zshrc
ln "script_dir"/zsh.zprofile "$spm_share"/zsh/.zprofile
