gnunet_namespace="$1"
publish_name="$2"
download_dir="$3"

# download to $project_dir/.cache/gnunet/download
# create reflinks to $project_dir and $project_dir/.data/gnunet/pristine
# to download new version, download gnunet dir file (non'recursively)
# use gnunet_directory to get CHK of the files to be downloaded
# use gnunet-publish --simulate-only to obtain the CHK of old files in $project_dir/.cache/gnunet/download
# if there is a common CHK with different filenames, rename the file
# if there is a gnunet dir file with a new CHK, do the above for it
# now download the whole directory recursively
# this method ensures that a simple file rename will not impose a download

# find the latest version
gnunet-search gnunet://fs/sks/$gnunet_namespace/"$publish_name"
# if above command succeeds (network is connected) but returns empty result: echo "not found"; exit
gnunet_url=

# before updating a project, first we compare .data/gnunet files
# if they match, it will be downloaded, and then we go to the next namespaces which must have the same content
# 	if not the content that most namespaces agree on, will be the downloaded result
# but if .data/gnunet files don't match, the one that most namespaces agree on, will be chosen
