echo "not yet implemented"; exit

gnunet_namespace="$(cat "$(dirname "$(readlink -f "$0")")"/../.meta/gns)"

state_dir="$XDG_STATE_HOME"
[ -z "$state_dir" ] && state_dir="$HOME/.local/state"

echo "UPM will try to download binary packages (instead of building from source), if they are available for your system"
printf "do you want to always built packages from source? (y/N) "
read -r ans
if [ "$ans" = y ]; then
	mkdir -p "$state_dir"/spm
	echo "build'from'src" > "$state_dir"/spm/config
fi

spm_dir="$state_dir/spm/builds/$gnunet_namespace/spm"
mkdir -p "$spm_dir"
cp "$(dirname "$0")/spm.sh" "$spm_dir/"
sh "$spm_dir"/spm.sh install "$gnunet_namespace" spm
