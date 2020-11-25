source "${ZSH_DIR}/functions.zsh"

# Make my python visible!!!
export PYTHONPATH="$(extend_path_var 'PYTHONPATH' "${ZSH_DIR}/snippets/python")"

add_path_if /usr/bin/{core_perl,vendor_perl}
add_path_if "$HOME/.cabal/bin"
add_path_before_if '/usr/local/bin'
add_path_before_if "$HOME/.local/bin"
add_path_before_if "$HOME/go/bin"

export PASSWORD_STORE_DIR="$HOME"

add_path_if "$ZSH_DIR/snippets/bash"

export_var_extend_bin_if "${HOME}/go" GOPATH

export_var_extend_bin_if '/usr/local/opt/go/libexec' GOROOT

export_var_extend_bin_if "${HOME}/.cargo" CARGOPATH

if command-exists rustc; then
  export RUSTC_SYSROOT="$(rustc --print sysroot)"
  export_var_if_new_dir "${RUSTC_SYSROOT}/lib/rustlib/src/rust/src" RUST_SRC_PATH
  export_var_if_new_dir "${RUSTC_SYSROOT}/lib/rustlib/etc" RUST_ETC_PATH
fi

if [[ -f '/etc/profile.d/jre.sh' ]]; then
    source /etc/profile.d/jre.sh
fi

if has-exec javac; then
  export JAVA_HOME="$(readlink -f "$(exec-find javac)" | sed -re 's#/bin/javac##g')"
fi
