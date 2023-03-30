source "${ZSH_DIR}/functions.zsh"

# Make my python visible!!!
export PYTHONPATH="$(extend_path_var 'PYTHONPATH' "${ZSH_DIR}/snippets/python")"

add_path_if /usr/bin/{core_perl,vendor_perl}
add_path_if "$HOME/.cabal/bin"
add_path_before_if '/usr/local/bin'
add_path_before_if "$HOME/.local/bin"
add_path_before_if "$HOME/go/bin"

add_path_if "$ZSH_DIR/snippets/bash"

if [[ -f '/etc/profile.d/jre.sh' ]]; then
    source /etc/profile.d/jre.sh
fi
