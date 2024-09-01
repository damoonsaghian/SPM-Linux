# install a portable system on a storage device
# prepare the device

# gmp mpfr mpc1

# compile linux with kernel modules for usb, ...

# cross compile
# install the target compiler; chain the compilers
# https://en.wikipedia.org/wiki/Cross_compiler
# https://gcc.gnu.org/onlinedocs/gcc-3.0.4/gcc/Cross-Compiler.html
# https://github.com/narke/gcc-cross-compiler
# https://github.com/crosstool-ng/crosstool-ng
# https://buildroot.org/
target_arch="$(uname -m)"
printf "supported architectures:
	x86_64
	x86
	aarch64
	armv7
	armhf
	riscv64
	ppc64le
	s390x
"
echo "choose target architecture (default is \"$target_arch\"): "
read -r target_arch
case "$target_arch" in
	x86_64) ;;
	x86) ;;
	aarch64) ;;
	armv7) ;;
	armhf) ;;
	riscv64) ;;
	ppc64le) ;;
	s390x) ;;
	*) target_arch="$(uname -m)" ;;
esac
