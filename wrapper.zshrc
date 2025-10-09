# -*- mode: sh; sh-shell: zsh; -*-

set -o pipefail

source "${ZSH_DIR}/colors.zsh"

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

declare -g ERROR_WRAP_INIT
# : ${ERROR_WRAP_INIT:='y'}

# We want to be able to immediately exit with an error message when sourcing our scripts, but if we
# call `exit` (or if we have any non-zero returns with `set -e` on), our shell will immediately
# exit, which usually closes the terminal and doesn't print any of the error messaging. By first
# sourcing a script in a subshell, we avoid that immediate exit, but any changes to the shell
# environment don't get propagated to the parent shell. So instead we just accept the 2x slowdown of
# running the script twice, so we never source the script at the top level unless we know it will
# succeed. If our scripts modify any OS state such as the filesystem, we might get weird errors, but
# we have tried to make our startup scripts idempotent anyway, and hopefully this will avoid
# any problems.
function maybe-wrap-source {
  local -r target="$1"
  local -r output="$2"
  if [[ -n "${ERROR_WRAP_INIT:-}" ]]; then
    if ((set -x; source "$target") &>"$output"); then
      source "$target"
    else
      local -ri rc="$?"
      cat "$output" >&2
      return "$rc"
    fi
  else
    source "$target"
  fi
}

# Similarly for here, as we may also wish to call shell functions which modify the
# local environment.
function maybe-execute-command {
  # FIXME: temp output unused!!
  local -r output="$1"
  local -ra cmd=( "${@:2}" )

  "${cmd[@]}"
}

declare -g LOAD_ACTION_DESCRIPTION LOAD_ACTION_TECHNIQUE

function verbose-perform-action {
  local -r target="$1"
  local -r script_output="$(mktemp)"
  case "$LOAD_ACTION_TECHNIQUE" in
    source-script)
      maybe-wrap-source "$target" "$script_output"
      ;;
    execute-command)
      maybe-execute-command "$script_output" "${target[@]}"
      ;;
    *)
      echo "unrecognized \${LOAD_ACTION_TECHNIQUE}=${LOAD_ACTION_TECHNIQUE}" >&2
      return 1
      ;;
  esac
}

declare -g verbose_init_nesting_level=0

# Pass in the associative array as a flattened list composed of key-value pairs, each separated by
# a colon ':'.
function verbose-perform-initialization-actions {
  setopt local_options
  set -uo pipefail

  local -ra args=( "$@" )

  local indent='> '
  if [[ "$verbose_init_nesting_level" -gt 0 ]]; then
    brown "\nsub-initialization!\n" | log-info-if-tty
    for _ in $(seq "$verbose_init_nesting_level"); do
      indent="-${indent}"
    done
  fi
  (( verbose_init_nesting_level++ ))
  # NB: implicitly iterate over $@.
  local description target
  local -i 10 rc
  for action_spec in "${args[@]}"; do
    # Split the entry by a colon ':'.
    description="${action_spec/%:*/}"
    target="${action_spec/#*:/}"

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
    color-start "$(lookup-color purple)"

    verbose-perform-action "$target"
    rc=$?
    color-end
    if [[ $rc -ne 0 ]]; then
      return $rc
    fi

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
