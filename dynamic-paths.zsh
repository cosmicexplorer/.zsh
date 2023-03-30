source "${ZSH_DIR}/functions.zsh"

export_var_extend_bin_if "${HOME}/go" GOPATH

export_var_extend_bin_if '/usr/local/opt/go/libexec' GOROOT

export_var_extend_bin_if "${HOME}/.cargo" CARGOPATH

if command-exists rustc; then
  export RUSTC_SYSROOT="$(rustc --print sysroot)"
  export_var_if_new_dir "${RUSTC_SYSROOT}/lib/rustlib/src/rust/src" RUST_SRC_PATH
  export_var_if_new_dir "${RUSTC_SYSROOT}/lib/rustlib/etc" RUST_ETC_PATH
fi

if has-exec javac; then
  export JAVA_HOME="$(readlink -f "$(exec-find javac)" | sed -re 's#/bin/javac##g')"
fi
