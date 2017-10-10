add_path_if /usr/bin/{core_perl,vendor_perl}
add_path_if "$HOME/.cabal/bin"
add_path_before_if /usr/local/bin
add_path_before_if "$HOME/.local/bin"
add_path_before_if "$HOME/go/bin"

export PASSWORD_STORE_DIR="$HOME"

export GPG_TTY="$(tty)"

add_path_if "$ZSH_DIR/snippets/bash"

GOPATH="$HOME/go"
GOROOT="/usr/local/opt/go/libexec"
path_extend_export GOPATH bin
path_extend_export GOROOT bin
