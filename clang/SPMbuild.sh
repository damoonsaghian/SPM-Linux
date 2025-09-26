spm_import llvm

cd "$pkg_dir/.cache/git"
gitag_clone

mkdir "$pkg_dir/.cache/build/$ARCH"
cd "$pkg_dir/.cache/build/$ARCH"
# build the project in "$pkg_dir/.cache/git/"
