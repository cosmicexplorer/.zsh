# -*- mode: sh; sh-shell: zsh; -*-

set -o pipefail

source "${ZSH_DIR}/colors.zsh"
source "${ZSH_DIR}/functions.zsh"

declare debug_init_log="$ZSH_DIR/.zsh-init-debug.log"

function non-tty-or-emacs {
  tty -s && [[ ! -v INSIDE_EMACS ]]
}
local tty_ish_exit_code="$(non-tty-or-emacs ; echo "$?")"
function log-info-if-tty {
  if [[ "$tty_ish_exit_code" -eq 0 ]]; then
    cat >&2
  else
    cat &>> "$debug_init_log"
  fi
}

function tee-to-debug-log {
  tee -a "$debug_init_log" >&2
}

function fail-from-stdin {
  tee-to-debug-log
  return 1
}

declare -g LOAD_ACTION_DESCRIPTION LOAD_ACTION_TECHNIQUE

function verbose-perform-action {
  local -r target="$1"
  case "$LOAD_ACTION_TECHNIQUE" in
    source-script)
      source "$target"
      ;;
    execute-command)
      "${target[@]}"
      ;;
    *)
      die "unrecognized \${LOAD_ACTION_TECHNIQUE}=${LOAD_ACTION_TECHNIQUE}"
      ;;
  esac
}

declare -g verbose_init_nesting_level=0

# Pass in the associative array as a flattened list composed of key-value pairs, each separated by
# a colon ':'.
function verbose-perform-initialization-actions {
  local indent='> '
  if [[ "$verbose_init_nesting_level" -gt 0 ]]; then
    brown "\nsub-initialization!\n" | log-info-if-tty
    for _ in $(seq "$verbose_init_nesting_level"); do
      indent="-${indent}"
    done
  fi
  (( verbose_init_nesting_level++ ))
  # NB: implicitly iterate over $@.
  for action_spec; do
    # Split the entry by a colon ':'.
    local description="${action_spec/%:*/}"
    local target="${action_spec/#*:/}"

    # NB: We unfortunately have to pass in each and every one of these `| log-info-if-tty` pipelines
    # each time, because otherwise zsh will literally just drop the `source` line and do it in a
    # subshell (atrocious).
    dark_gray "${indent}${LOAD_ACTION_DESCRIPTION} " | log-info-if-tty
    yellow "$description" | log-info-if-tty
    dark_gray '...' | log-info-if-tty

    # We only send stderr output to the logfile, since sometimes we want the ability to
    # interact with our zsh setup scripts (e.g. to set up CPAN on a new machine).
    # TODO: `source` does NOT fail when an individual line errors, and just returns the code of the
    # last line of the script!!! Abhorrent!!!
    color-start purple

    verbose-perform-action "$target" \
      || (color-end ; return 1)
    color-end

    light_green 'success' | log-info-if-tty
    light_gray '!\n' | log-info-if-tty
  done
  (( verbose_init_nesting_level-- ))
}

function verbose-load-scripts {
  LOAD_ACTION_DESCRIPTION='Loading' LOAD_ACTION_TECHNIQUE='source-script' \
    verbose-perform-initialization-actions \
    "$@"
}

function verbose-execute-commands {
  LOAD_ACTION_DESCRIPTION='Executing' LOAD_ACTION_TECHNIQUE='execute-command' \
    verbose-perform-initialization-actions \
    "$@"
}
