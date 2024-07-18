# if arch is ppc64el:
# , create a HFS partition
# , make the root dir blessed
# , create a CHRP script with file type "tbxi"
# , create "/syslinux/syslinux.cfg" or "/syslinux.cfg"
# https://github.com/void-ppc/void-ppc-docs/blob/master/src/installation/live-images/booting.md
# https://manpages.debian.org/jessie/yaboot/bootstrap.8.en.html
#
# otherwise:
#
# if arch is x86 or x86_64: syslinux
# https://wiki.archlinux.org/title/Syslinux
#
# EFI: unified kernel
