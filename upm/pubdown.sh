# download/publish files to gnunet and hashbang
# download from hashbang, if gnunet executable is not available (eg during installation for the fisrt time)

# https://www.gnunet.org/en/use.html
# https://git.gnunet.org/gnunet.git/tree/src
# https://docs.gnunet.org/latest/users/subsystems.html
# https://docs.gnunet.org/latest/users/configuration.html#access-control-for-gnunet
# https://manpages.debian.org/unstable/gnunet/gnunet.1.en.html
# https://manpages.debian.org/unstable/gnunet/
# https://wiki.archlinux.org/title/GNUnet

# "$project_dir/.data/project" file contains these lines:
# , project name
# , the level of anonymity
# , gnunet namespace (public key of the ego used for publishing)
# , extra gnunet namespaces can follow
# if this file exists use it
# if not, try to copy from a siblibg project "$project_dir/../*/.data/gnunet", and just set project name
# and if failed, ask the user, and create one

# at least 50% namespaces (excluding revoked ones) must agree

# https://docs.gnunet.org/latest/users/gns.html#revocation
# https://docs.gnunet.org/latest/developers/apis/revocation.html
# the revoke message will be pre calculated (can take days or weeks)

# hash of files followed by their path (relative to projet dir) are stored in .data/hashes file
# the hashes of directories is obtained from the hash of the alphabetical list of relative paths of files and their hashes
# .data/hashes will be signed with ssh-keygen (using the EdDSA key of the gnunet namespace)
# .data/hashes will be used during download and publish, such that only changed files will be transfered

gn_download() {
	dest_dir="$1"
}

gn_publish() {
	# create ref links of the files in $project_dir/.data/gnunet/publish
	# skip .cache directory, and symlinks
	# run gnunet-publish
	# this way GNUnet can publish the files using the indexed method
	
	# gnunet://fs/sks/$gnunet_namespace/$publish_name
}

web_download() {
	# curl or wget
	# download .data/hashes
}

hashbang_register() {
	# we still need a website so the unfortunate users of conventional internet can see and find us
	
	# hasbang can be used as free web host that allows to signup using http post
	# https://github.com/hashbang/hashbang.sh/blob/master/src/hashbang.html
	# https://github.com/hashbang/shell-server/blob/master/ansible/tasks/packages/main.yml
	# create a user in one of "hashbang.sh" servers
	# https://github.com/hashbang/hashbang.sh/blob/master/src/hashbang.sh
	
	# currently, the ~/Public folder isn't exposed over HTTP by default
	# use the `SimpleHTTPServer.service` systemd unit file (in `~/.config/systemd/user`, modify it to set port)
	# download ~/.config/systemd/user/SimpleHTTPServer@.service
	# rename to SimpleHTTPServer@1025.service and upload to ~/.config/systemd/user/
	# https://github.com/hashbang/dotfiles/blob/master/hashbang/.config/systemd/user/SimpleHTTPServer%40.service
	# https://github.com/hashbang/shell-server/blob/master/ansible/tasks/hashbang/templates/etc/skel/Mail/new/msg.welcome.j2
	
	# create an html web'page "~/Public/project_name/index.html", showing the files in the project
	# when converting to html, convert tabs to html tables, to have elastic tabstops
	
	# hashbang init:
	
	# if "remote_host" or "user" are empty, ask for them
	
	printf "\nHost %s\n  User %s\n" "$remote_host" "$user" >> ~/.ssh/config
	
	{ echo "$user" | sed -n "/^[a-z][a-z0-9]{0,30}$/!{q1}"; } || {
		echo "\"$user\" is not a valid username"
		echo "a valid username must:"
		echo ", be between between 1 and 31 characters long"
		echo ", consist of only 0-9 and a-z (lowercase only)"
		echo ", begin with a letter"
		exit 1
	}
	
	ssh "$user"@"$remote_host" && return
	
	# if there is no SSH keys, create a key pair
	# ssh-keygen -t ed25519
	# openssh key format: ssh-ed25519 ...
	
	echo
	echo " please choose a server to create your account on"
	echo
	hbar
	printf -- '  %-1s | %-4s | %-36s | %-8s | %-8s\n' \
		"#" "Host" "Location" "Users" "Latency"
	hbar
	
	host_data=$(wget -q -O - --header 'Accept:text/plain' https://hashbang.sh/server/stats)
	
	while IFS="|" read -r host _ location current_users max_users _; do
		host=$(echo "$host" | cut -d. -f1)
		latency=$(time_cmd "wget -q -O /dev/null \"${host}.hashbang.sh\"")
		n=$((n+1))
		printf -- '  %-1s | %-4s | %-36s | %8s | %-8s\n' \
			"$n" \
			"$host" \
			"$location" \
			"$current_users/$max_users" \
			"$latency"
	done <<-INPUT
	"$host_data"
	INPUT
	
	echo
	while true; do
		printf ' Enter Number 1-%i : ' "$n"
		read -r choice
		case "$choice" in
			''|*[!0-9]*) number="no";;
		esac
		if [ "$number" != "no" ] && [ "$choice" -ge 1 ] && [ "$choice" -le $n ]; then
			break;
		fi
	done
	
	host=$(echo "$host_data" | head -n "$choice" - | tail -n1 | cut -d \| -f1)
	
	pulic_key=$(cat ~/.ssh/id_ed25519.pub)
	host=de1.hashbang.sh
	wget --post-data="{\"user\":\"$user\",\"key\":\"$public_key\",\"host\":\"$host\"}" \
		--header='Content-Type: application/json' https://hashbang.sh/user/create
	
	# use ssh-keygen to sign/verify files
	# use gnunet-identity to obtain the Ed25519 key
	# openssh public key format: ed25519 ... user@hostname
	# openssh private key format:
	# -----BEGIN OPENSSH PRIVATE KEY-----
	# base64-encoded data, that may also be encrypted with a passphrase
	# -----END OPENSSH PRIVATE KEY-----
	# https://hstechdocs.helpsystems.com/manuals/globalscape/eft82/mergedprojects/admin/ssh_key_formats.htm
	# https://en.wikipedia.org/wiki/PKCS_8
}

web_publish() {
	# curl or wget
	
	# if there is no .data/url, call hashbang_register
	
	# if .data/url is empty, exit quietly
}

mkpristine() {
	dest_dir="$1"
	cp -r --reflink=auto "$dest_dir"/* "$dest_dir"/.data/gnunet/pristine
	# to download new version, download gnunet dir file (non'recursively)
	# use gnunet-directory to get CHK of the files to be downloaded
	# use gnunet-publish --simulate-only to obtain the CHK of old files in $project_dir/.cache/gnunet/download
	# if there is a common CHK with different filenames, rename the file
	# if there is a gnunet dir file with a new CHK, do the above for it
	# now download the whole directory recursively
	# this method ensures that a simple file rename will not impose a download
}

case "$1" in
download)
	url="$1"
	dest_path="$2"
	
	# url protocol can be gnunet or http
	# gn_download
	# web_download
;;
publish)
	src_dir="$1"
	url="$2"
	
	# url protocol can be gnunet or http
	# gn_publish
	# web_publish
;;
*) echo "usage guide:"
echo "	ushare download <url> <destination-path>"
echo "	ushare publish <source-path> <url>"
echo "URL can be GNUnet or an HTTP link"
;;
esac
