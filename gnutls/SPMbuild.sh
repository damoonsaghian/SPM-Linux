spm_import nettle

# https://pkgs.alpinelinux.org/package/edge/main/x86_64/ca-certificates-bundle

# disable p11-kit, cause it's useless
# because when a system is compromized, though it can protect the private key itself,
# it can't prevent using the private key (eg for signing)

# build the openssl compatibility wrapper
