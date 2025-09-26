# https://github.com/qt/qtbase
# https://github.com/qt/qtbase/blob/dev/config_help.txt
# cmake args: -DFEATURE_glib=OFF -DFEATURE_xcb_xlib=OFF

# https://github.com/qt/qtdeclarative

# gnutls implementes a compatibility wrapper for openssl; try to use that
# if it failed, use openssl
#
# QtNetwork depends on openssl and does not support HTTP3
# it would be good to reimplement it using Curl, in the future
# https://doc.qt.io/qt-6/qtnetwork-module.html
# https://curl.se/libcurl/c/

# https://github.com/qt/qtimageformats
# https://github.com/qt/qtsvg
# https://invent.kde.org/frameworks/kimageformats/
