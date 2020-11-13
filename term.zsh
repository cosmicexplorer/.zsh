# -*- mode: sh; sh-shell: zsh -*-

function modify-TERM-compat {
  export ORIG_TERM="$TERM"
  export COMPAT_TERM='xterm-256color'
  if [[ ! -v TERM ]]; then
    # TODO: Not sure when this would happen?
    die "no TERM! exiting..."
  elif [[ "$TERM" =~ "dumb|emacs" ]]; then
    # This   avoids   an  issue   with   using   RPROMPT  in   emacs   where   the  output   becomes
    # completely unreadable.
    export TERM="${COMPAT_TERM}"
    unset RPROMPT
    export PROMPT="X> "
  else
    export RPROMPT="$RPROMPT_code$RPROMPT_jobs$RPROMPT_time"
  fi
}
