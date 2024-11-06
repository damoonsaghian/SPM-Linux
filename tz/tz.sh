#!/apps/env sh
set -e

script_dir="$(dirname "$0")"

location_from_offset() {}

if [ "$1" = set ]; then
	# if $2 is an offset number
	if []; then
		tz="$(location_from_offset)"
	else
		tz="$2"
	fi
	
	[ -f "$script_dir"/tzdata/"$tz" ] &&
		ln -s "$script_dir"/tzdata/"$tz" /etc/localtime
elif [ "$1" = continents ]; then
	ls -1 -d "$script_dir"/tzdata/*/ | cut -d / -f5
elif [ "$1" = cities ]; then
	ls -1 "$script_dir"/tzdata/"$2"/* | cut -d / -f6
elif [ "$1" ]; then
	location_from_offset "$1"
else
	echo "usage:"
	echo "	tz set <offset|city/continent>"
	echo "	tz continents"
	echo "	tz cities <continent>"
	echo "	tz <offset>"
fi
