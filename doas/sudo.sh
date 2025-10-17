[ "$1" = "--passwd" ] && {
	root_dir="$2"
	# read password
	# store it in "$root_dir"/var/lib/passwd hashed, without read permission for any user other than root
	exit
}

# ask for password, and if correct exec "$1"
