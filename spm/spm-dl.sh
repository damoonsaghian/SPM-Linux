pkg_url="$1"
build_url=
gn_namespace="$(echo "$gn_url" | cut -d / -f 1)"
pkg_name="$(echo "$pkg_id" | cut -d / -f 2)"

# download directory
pkg_dir="$cache_dir/spm/$pkg_name"

build_dir="$cache_dir/spm/builds/$gn_namespace/$pkg_name"

# if there is no "always_build_from_src" line in "$state_dir/spm/config",
# 	and the corresponding directory for the current architecture is available in $build_url,
# 	just download that into "$cache_dir/spm/builds-dl/$gn_namespace/$pkg_name"
# then spm_build all the packages mentioned in the included "spmdeps" file

# try to download the package from "$pkg_url" to "$pkg_dir/"
# if not root, before downloading a package first see if it already exists in /var/cache/spm/builds-dl/
# if so, sudo spm update <package-url>, then make hard links in ~/.cache/spm/builds-dl/
