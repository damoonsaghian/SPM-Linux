/*
https://git.suckless.org/ubase/file/passwd.c.html
https://git.busybox.net/busybox/tree/loginutils/cryptpw.c
https://github.com/rfc1036/whois/blob/next/mkpasswd.c

if argv[0] begin with "/", find the realpath of argv[0], then the dirname, then ../../../var/lib/sudo/passwd
otherwise just use /var/lib/sudo/passwd

printf "set root password: "
while true; do
	read -rs root_password
	printf "enter password again: "
	read -rs root_password_again
	[ "$root_password" = "$root_password_again" ] && break
	echo "the entered passwords were not the same; try again"
	printf "set root password: "
done
root_password_hashed="$($root_password)"
mkdir -p "$spm_linux_dir"/var/state/sudo/passwd
echo "$root_password_hashed" > "$spm_linux_dir"/var/state/sudo/passwd

printf "set lock'screen password: "
while true; do
	read -rs lock_password
	printf "enter password again: "
	read -rs lock_password_again
	[ "$lock_password" = "$lock_password_again" ] && break
	echo "the entered passwords were not the same; try again"
	printf "set lock'screen password: "
done
lock_password_hashed=
echo "$lock_password_hashed" >> "$spm_linux_dir"/var/state/sudo/passwd
*/
