#!/apps/env sh
set -e

script_dir="$(dirname "$(realpath "$0")")"

if [ "$1" = set ]; then
	tz="$2"
	[ -f "$script_dir"/tzdata/"$tz" ] &&
		ln -s "$script_dir"/tzdata/"$tz" /var/lib/netman/tz
elif [ "$1" = continents ]; then
	ls -1 -d "$script_dir"/tzdata/*/ | cut -d / -f5
elif [ "$1" = cities ]; then
	ls -1 "$script_dir"/tzdata/"$2"/* | cut -d / -f6
elif [ "$1" = check ]; then
	# get timezone from location
	# https://www.freedesktop.org/software/geoclue/docs/gdbus-org.freedesktop.GeoClue2.Location.html
	# https://github.com/evansiroky/timezone-boundary-builder (releases -> timezone-with-oceans-now.geojson.zip)
	# https://github.com/BertoldVdb/ZoneDetect
	# tz set "$continent/$city"
else
	echo "usage:"
	echo "	tz set <offset|city/continent>"
	echo "	tz continents"
	echo "	tz cities <continent>"
	echo "	tz check"
fi