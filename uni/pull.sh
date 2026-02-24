
pull() {
	# cp --rflink=auto "$project_dir"/* "$project_dir"/.cache/ushare/pull/
}

pullreq() {
	# first publish the pristine and the working directory (except .cache)
	# then send the two addresses to the main developer
}

pullret() {
	pristine_uri="$1"
	wdir_uri="$2"
	# to retrieve a pull request:
	# , send a message to the main developer
	# , unpublish the two links (printine and the working directory)
}
