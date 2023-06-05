# source "${ZSH_DIR}/functions.zsh"

# This  is meant  to  be an  idempotent, re-entrant  operation.  No clue  if  that works  in all  or
# any cases.
function startx-idempotent {
  if command-exists-and-not-running startx; then
    startx
  fi
}
