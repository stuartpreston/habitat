pkg_name=hab-bintray-publish
pkg_origin=core
pkg_version=$(cat "$PLAN_CONTEXT/../../VERSION")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('apachev2')
pkg_source=nosuchfile.tar.gz
pkg_deps=(core/coreutils core/util-linux core/bash core/zip core/tar core/gzip core/jfrog-cli
          core/grep core/findutils core/gawk core/hab core/docker)
pkg_bin_dirs=(bin)
programs=(publish-hab publish-studio)

do_build() {
  cp -v $PLAN_CONTEXT/../../components/studio/build-docker-image.sh \
    build-docker-image

  local run_path=""
  for dep in "${pkg_deps[@]}"; do
    if [[ -z $run_path ]]; then
      run_path="$(pkg_path_for $dep)/bin"
    else
      run_path="$(pkg_path_for $dep)/bin:$run_path"
    fi
  done

  for program in "${programs[@]}"; do
    cp -v $PLAN_CONTEXT/bin/${program}.sh ${program}

    # Use the bash from our dependency list as the shebang. Also, embed the
    # release version of the program.
    sed \
      -e "s,#!/bin/bash$,#!$(pkg_path_for bash)/bin/bash," \
      -e "s,@author@,$pkg_maintainer,g" \
      -e "s,@path@,$pkg_prefix/bin:$run_path,g" \
      -e "s,@version@,$pkg_version/$pkg_release,g" \
      -i $program
  done
}

do_install() {
  for program in "${programs[@]}" build-docker-image; do
    install -v -D $program $pkg_prefix/bin/$program
  done
}

# Turn the remaining default phases into no-ops

do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_prepare() {
  return 0
}
