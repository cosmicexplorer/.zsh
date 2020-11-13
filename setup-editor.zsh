typeset -ga PREFERRED_EDITORS=(
  emacsclient
  vim
  nano
)

function select-editors {
  for editor; do
    command-exists "$editor" \
      && echo "$editor"
  done
}

# "$(select-editors "${PREFERRED_EDITORS[@]}" | head -n1)"

function display-known-editors {
  cat <<EOF
Known editors:
Name: Definition
EOF
  for editor in "${PREFERRED_EDITORS[@]}"; do
    local entry="$(command-exists "$editor" && which "$editor" || echo "<not found>")"
    printf '%s:\t%s\n' "$editor" "$entry"
  done
}

function make-editor-selection-global {
  local -r editor="$1"

  if [[ -z "$editor" ]]; then
    return 0
  fi

  if true (${${(M)PREFERRED_EDITORS[@]:#${editor}}:?'Unknown editor'}) ; then
    export EDITOR="$editor"
    export GIT_EDITOR="$editor"
    export VISUAL="$editor"
  else
    die "Editor ${editor} was not recognized."
  fi
}
