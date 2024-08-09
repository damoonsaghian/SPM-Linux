project_dir="$(dirname "$0")"

# git://busybox.net/busybox/tag/?h=1_36_1

# init
# PATH=/apps/bb:/apps

cp "$project_dir"/system.sh "$project_dir"/.cache/spm/bin/system
chmod +x "$project_dir"/.cache/spm/bin/system
