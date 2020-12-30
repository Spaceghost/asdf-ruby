RUBY_INSTALL_VERSION="${ASDF_RUBY_INSTALL_VERSION:-v0.8.1}"
RUBY_INSTALL_TAG="$RUBY_INSTALL_VERSION"
echoerr() {
  >&2 echo -e "\033[0;31m$1\033[0m"
}

ensure_ruby_install_setup() {
  ensure_ruby_install_installed
}

ensure_ruby_install_installed() {
    local ruby_install_version

    if [ ! -f "$(ruby_install_path)" ]; then
        download_ruby_install
    else
        current_ruby_install_version="$("$(ruby_install_path)" --version | cut -d ' ' -f2)"
        # If ruby-install install does not start with 'v',
        # add 'v' to beginning of version
        if [ ${current_ruby_install_version:0:1} != "v" ]; then
          current_ruby_install_version="v$current_ruby_install_version"
        fi
        if [ "$current_ruby_install_version" != "$RUBY_INSTALL_VERSION" ]; then
            # If the ruby-install directory already exists and the version does not
            # match, remove it and download the correct version
            rm -rf "$(ruby_install_dir)"
            download_ruby_install
        fi
    fi
}

download_ruby_install() {
    # Print to stderr so asdf doesn't assume this string is a list of versions
    echoerr "Downloading ruby-install..."
    local install_dir="$(ruby_install_source_dir)"

    # Remove directory in case it still exists from last download
    rm -rf $install_dir

    # Clone down and checkout the correct ruby-install version
    git clone https://github.com/postmodern/ruby-install.git $install_dir >&2 >/dev/null
    (cd $install_dir; git checkout $RUBY_INSTALL_TAG >&2 >/dev/null)

    cd $install_dir
    # Install in the ruby-install dir
    PREFIX="$(ruby_install_dir)" make install

    # Remove ruby-install source dir
    rm -rf $install_dir
}

asdf_ruby_plugin_path() {
    echo "$(dirname "$(dirname "$0")")"
}
ruby_install_dir() {
    echo "$(asdf_ruby_plugin_path)/ruby-install"
}

ruby_install_source_dir() {
    echo "$(asdf_ruby_plugin_path)/ruby-install-source"
}

ruby_install_path() {
    echo "$(ruby_install_dir)/bin/ruby-install"
}
