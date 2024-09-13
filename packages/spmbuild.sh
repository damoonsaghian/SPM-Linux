# gnutls uses nettle (good choice: simple, fast, cpu accel)
# 	https://www.gnutls.org/manual/html_node/Cryptographic-Backend.html
# 	https://git.lysator.liu.se/nettle/nettle
# webkitgtk uses libgcrypt (not good)
# libsecret can be configured to use gnutls instead of libgcrypt
# 	https://gitlab.gnome.org/GNOME/libsecret/-/blob/master/meson.build
# gnunet uses gnutls and libgcrypt and libsodium (for its cpu acceleration)
# 	i think it can easily replace libsodium with gnutls or nettle
# 	also it can gradually replace gcrypt with nettle
# 	https://www.gnutls.org/manual/html_node/Using-GnuTLS-as-a-cryptographic-library.html

# gnutls/nettle does not yet support post quantum crypto
# OpenSSL supports it using liboqs (which is yet an experimental effort)
# 	https://en.wikipedia.org/wiki/Post-quantum_cryptography
# 	https://openquantumsafe.org/
# but i don't like the technical design of openssl
# it implements everything internally, instead of using better available options like GMP

# disable pkcs#11 support

# https://pkgs.alpinelinux.org/package/edge/main/x86_64/ca-certificates-bundle
