# -*- mode: sh; sh-shell: zsh; -*-
# defining $ZSH_DIR makes sourcing other files easy -- see this link for details
# https://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
export ZSH_DIR="${ZSH_DIR}"
# NB: Our only undeclared dependency is on terminal colors, because we use them for error messages
# when a script doesn't load correctly!
source "$ZSH_DIR/colors.zsh"

set -o pipefail

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

# Pass in the associative array as a flattened list composed of key-value pairs, each separated by
# a colon ':'.
function verbose-load-scripts {
  # NB: implicitly iterate over $@.
  for script_entry; do
    local script_type="${script_entry/%:*/}"

    local source_file="${script_entry/#*:/}"
    # NB: We unfortunately have to pass in each and every one of these `| log-info-if-tty` pipelines
    # each time, because otherwise zsh will literally just drop the `source` line and do it in a
    # subshell (atrocious).
    dark_gray '# Loading ' | log-info-if-tty
    yellow "$script_type" | log-info-if-tty
    dark_gray '...' | log-info-if-tty

    # We only send stderr output to the logfile, since sometimes we want the ability to
    # interact with our zsh setup scripts (e.g. to set up CPAN on a new machine).
    # TODO: `source` does NOT fail when an individual line errors, and just returns the code of the
    # last line of the script!!! Abhorrent!!!
    color-start purple
    source "$source_file" || (color-end ; return 1)
    color-end

    light_green 'success' | log-info-if-tty
    light_gray '!\n' | log-info-if-tty
  done

}
