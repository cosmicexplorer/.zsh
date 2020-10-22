# -*- mode: sh; sh-shell: zsh; -*-
# defining $ZSH_DIR makes sourcing other files easy -- see this link for details
# https://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
export ZSH_DIR="$HOME/.zsh"
# NB: Our only undeclared dependency is on terminal colors, because we use them for error messages
# when a script doesn't load correctly!
source "$ZSH_DIR/colors.zsh"

set -euo pipefail

declare debug_init_log="$ZSH_DIR/.zsh-init-debug.log"

local tty_exit_code="$(tty -s ; echo "$?")"
function log-info-if-tty {
  if [[ "$tty_exit_code" -eq 0 ]]; then
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

# EXTREMELY surprisingly, in zshparam(1), it is revealed that associative arrays have no order.
declare -ga startup_order=(
  paths
  full_setup
  aliases
)
declare -ga source_files=(
  ~/.local.zsh
  ~/.zsh/.zshrc
  ~/.zsh/aliases.zsh
)
if [[ "${#startup_order[@]}" -ne "${#source_files[@]}" ]]; then
  fail-from-stdin <<EOF
$(light_red Failed to match up starting resource files!)
$(red Names were:)
$(yellow ${(F)startup_order[@]})
$(red Source files were:)
$(yellow ${(F)source_files[@]})
EOF
fi

function load_sources {
  for type; do
    dark_gray 'Loading '
    yellow "$type"
    dark_gray '...'
    # We only send stderr output to the logfile, since sometimes we want the ability to
    # interact with our zsh setup scripts (e.g. to set up CPAN on a new machine).
    # TODO: `source` does NOT fail when an individual line errors, and just returns the code of the
    # last line of the script!!! Abhorrent!!!
    local source_file="${source_files[${startup_order[(i)$type]}]}"
    # NB: If the source file doesn't exist, it will *actually* fail at least.
    if ! source "$source_file" 2>>(tee-to-debug-log); then
      fail-from-stdin <<EOF
Failed to load $source_file for phase $type! Please check $(readlink -f $debug_init_log) for details.
EOF
    else
      light_green 'success'
      light_gray '!\n'
    fi
  done
}

# Pass in the associative array as a flattened list composed of key-value pairs, each separated by
# a space.
if load_sources "${startup_order[@]}"; then
  set +euo pipefail
  return 0
else
  return 1
fi
