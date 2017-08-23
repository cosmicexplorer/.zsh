add_path_if /usr/bin/{core_perl,vendor_perl}
add_path_if "$HOME/.cabal/bin"
add_path_before_if /usr/local/bin
add_path_before_if "$HOME/.local/bin"

export PASSWORD_STORE_DIR="$HOME"

export GPG_TTY="$(tty)"
