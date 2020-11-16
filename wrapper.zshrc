# -*- mode: sh; sh-shell: zsh; -*-
# defining $ZSH_DIR makes sourcing other files easy -- see this link for details
# https://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
export ZSH_DIR="$HOME/.zsh"
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

# EXTREMELY surprisingly, in zshparam(1), it is revealed that associative arrays have no order.
# FIXME: no inline comments in arrays!!! but also allow more official rust/(coffeescript)-like docstrings, e.g.:
###
#
#*find_closest_command_not_found.zsh:*
#- add command recognition i.e. "did you mean <x>?"
#  - like ubuntu's command-not-found module
#
###
# TODO: we want to call the "main function"  of setup-editor.zsh, but we can't do that without doing
# it at  the top level, in  the file itself!  And we want  `source` to avoid modifying  anything but
# definitions. So here:
# (1) Interface definitions for modules.
# (2) Make that interface have a "main function" so we can *separate sourcing and startup!*
declare -ga startup_order=(
  paths
  local_config
  full_setup
  aliases
  env_parallel
  find_closest_command
  setup_editor
)
declare -ga source_files=(
  "$HOME/.zsh/paths.zsh"
  "$HOME/.local.zsh"
  "$HOME/.zsh/.zshrc"
  "$HOME/.zsh/aliases.zsh"
  "$HOME/.zsh/parallel_wrapper.zsh"
  "$HOME/.zsh/find_closest_command_not_found.zsh"
  "$HOME/.zsh/setup-editor.zsh"
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

# Pass in the associative array as a flattened list composed of key-value pairs, each separated by
# a space.
# NB: We unfortunately have to pass in each and every one of these `| log-info-if-tty` pipelines
# each time, because otherwise zsh will literally just drop the `source` line and do it in a
# subshell (atrocious).
for script_type in "${startup_order[@]}"; do
  dark_gray '# Loading ' | log-info-if-tty
  yellow "$script_type" | log-info-if-tty
  dark_gray '...' | log-info-if-tty
  # We only send stderr output to the logfile, since sometimes we want the ability to
  # interact with our zsh setup scripts (e.g. to set up CPAN on a new machine).
  # TODO: `source` does NOT fail when an individual line errors, and just returns the code of the
  # last line of the script!!! Abhorrent!!!
  local source_file="${source_files[${startup_order[(i)$script_type]}]}"
  color-start purple
  source "$source_file" || (color-end ; return 1)
  color-end
  light_green 'success' | log-info-if-tty
  light_gray '!\n' | log-info-if-tty
done
