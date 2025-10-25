# source "${ZSH_DIR}/functions.zsh"

# Link $PYTHONPATH and $pythonpath together as scalar and array variables with entries separated by
# a colon.
if [[ -n "${PYTHONPATH:-}" ]]; then
  declare -x -T PYTHONPATH="${PYTHONPATH:-}" pythonpath ':'
else
  declare -x -T PYTHONPATH pythonpath ':'
fi
# Make my python visible!!!
pythonpath+="${ZSH_DIR}/snippets/python"

declare maybe_dir
for maybe_dir in /usr/bin/{core_perl,vendor_perl} "$HOME/.cabal/bin" "$ZSH_DIR/snippets/bash"; do
  add-path-if "$maybe_dir"
done

for maybe_dir in /usr/local/bin "$HOME/.local/bin" "$HOME/go/bin"; do
  add-path-before-if "$maybe_dir"
done

# .............this depends on a function append_path which doesn't exist, jfc
# if [[ -f '/etc/profile.d/jre.sh' ]]; then
#     source /etc/profile.d/jre.sh
# fi
