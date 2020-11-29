# -*- mode: sh; sh-shell: zsh -*-

source "${ZSH_DIR}/functions.zsh"

# gpg-agent is very often provided as a systemd service -- this sets it up if it doesn't.
# This  is meant  to  be an  idempotent, re-entrant  operation.  No clue  if  that works  in all  or
# any cases.
function setup-gpg-agent-idempotent {
  export GPG_TTY="$(tty)"
  if command-exists-and-not-running gpg-agent; then
    gpg-agent --daemon \
      || return 0
  fi
}
