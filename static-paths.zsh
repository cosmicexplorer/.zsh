# source "${ZSH_DIR}/functions.zsh"

# Link $PYTHONPATH and $pythonpath together as scalar and array variables with entries separated by
# a colon.
declare -x -T PYTHONPATH="${PYTHONPATH:-}" pythonpath ':'
# Make my python visible!!!
pythonpath+="${ZSH_DIR}/snippets/python/"

declare maybe_dir
for maybe_dir in /usr/bin/{core_perl,vendor_perl} "$HOME/.cabal/bin" "$ZSH_DIR/snippets/bash"; do
  add-path-if "$maybe_dir"
done

for maybe_dir in /usr/local/bin "$HOME/.local/bin" "$HOME/go/bin"; do
  add-path-before-if "$maybe_dir"
done

if [[ -f '/etc/profile.d/jre.sh' ]]; then
    source /etc/profile.d/jre.sh
fi
