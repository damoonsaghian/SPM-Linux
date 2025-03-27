spm_build $gnunet_namespace clang

spm_import $gnunet_namespace llvm

# https://github.com/c3lang/c3c
cd "$pkg_dir/.cache/git"
gitag_clone https://github.com/c3lang/c3c.git

mkdir "$pkg_dir/.cache/build/$ARCH"
cd "$pkg_dir/.cache/build/$ARCH"
cmake "$pkg_dir/.cache/git/c3c"
make

# test built product
"$pkg_dir/.cache/build/$ARCH/c3c" compile-run "$pkg_dir/.cache/git/c3c/resources/testfragments/helloworld.c3"
