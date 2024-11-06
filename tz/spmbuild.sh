project_dir="$(dirname "$0")"

# in ".cache/spm/tzdata" directory:
# git clone https://github.com/eggert/tz
# only produce "right" timezones

ln "$project_dir"/tz.sh "$project_dir"/.cache/spm/apps/tz
chmod +x "$project_dir"/.cache/spm/apps/tz
