upm_import qt
upm_import quickshell # needed for Process qml type
upm_import curl
upm_import mauikit-filebrowsing
upm_import archive

upm_xcript inst/app uni

ln "$pkg_dir/.data/uni.svg" "$pkg_dir/.cache/upm/$ARCH/app/uni.svg"
