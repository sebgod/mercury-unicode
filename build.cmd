@pushd %~dp0
make MMC=mercury_compile copy
@pushd build
make MMC=mercury_compile %*
@popd

@popd
