# source "${ZSH_DIR}/functions.zsh"

function setup-gopath-goroot {
  if [[ ! -v GOPATH ]]; then
    local -r default_go_dir="${HOME}/go"
    if [[ ! -d "$default_go_dir" ]]; then
      err 'creating GOPATH...'
      mkdir -pv "${default_go_dir}/bin"
    fi
    export GOPATH="$default_go_dir"
  fi


  local -r go_bin_dir="${GOPATH}/bin"
  if [[ -d "$go_bin_dir" ]]; then
    path+="$go_bin_dir"
  else
    die "unrecognized \${GOPATH}=${GOPATH} had no bin dir"
  fi

  if [[ -v GOROOT ]]; then
    local -r goroot_bin_dir="${GOROOT}/bin"
    if [[ -d "$goroot_bin_dir" ]]; then
      path+="$goroot_bin_dir"
    else
      die "unrecognized \${GOROOT}=${GOROOT} had no bin dir"
    fi
  fi
}

function setup-rustup {
  if [[ ! -v CARGOPATH ]]; then
    export CARGOPATH="${HOME}/.cargo"
  fi
  local -r cargo_bin_dir="${CARGOPATH}/bin"
  path+="$cargo_bin_dir"
}

function probe-rust-src-paths {
  if command-exists rustc; then
    export RUSTC_SYSROOT="$(rustc --print sysroot)"
    local -r rust_src_path="${RUSTC_SYSROOT}/lib/rustlib/src/rust/src"
    local -r rust_etc_path="${RUSTC_SYSROOT}/lib/rustlib/etc"
    if [[ ! ( -d "$rust_src_path" && -d "$rust_etc_path" ) ]]; then
      err
      err "unrecognized \${RUSTC_SYSROOT}=${RUSTC_SYSROOT} had no src or etc dirs!"
    fi
    export RUST_SRC_PATH="$rust_src_path"
    export RUST_ETC_PATH="$rust_etc_path"
  fi
}

function locate-java-home {
  if has-exec javac; then
    export JAVA_HOME="$(readlink -f "$(exec-find javac)" | sed -re 's#/bin/javac##g')"
  fi
}

local -ra operations=(
  setup-gopath-goroot
  setup-rustup
  probe-rust-src-paths
  locate-java-home
)

verbose-execute-commands "${operations[@]}"
