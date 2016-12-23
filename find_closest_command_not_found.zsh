#!/bin/zsh

# overrideable
export LEVENSHTEIN_CMD_DIST=3
export LEVENSHTEIN_TRUNCATE=16
export CMD_ALL=''

# all platforms, needs perl
function use_leven {
  "$ZSH_DIR/levenshtein_complete.zsh" "$1"
}
# ubuntu only (or anyone)
function use_cmd_not_found {
  python3 "$ZSH_DIR/command-not-found" -- "$1"
}

# very shallow check for internet connectivity so we don't wait on searching
# package archives for no reason
function do_if_internet_route {
  (ip route | read) && $@
}
function use_pacman {
  cmd="$1"
  echo -e "\033[1;33msearching pacman repositories...\033[1;0m"
  pacman -Ss --color always "$cmd" | "$ZSH_DIR/group_results.pl" 2
}
function use_yaourt {
  cmd="$1"
  echo -e "\033[1;33msearching pacman repositories and AUR...\033[1;0m"
  yaourt -Ss --color "$cmd" | "$ZSH_DIR/group_results.pl" 2
}
function use_apt {
  cmd="$1"
  echo -e "\033[1;33msearching apt cache...\033[1;0m"
  apt-cache search "$cmd" | \
    sed -r -e "s/^([^[:space:]]+)[[:space:]]+-[[:space:]]+(.+)\$/$(tput setaf 6)$(tput bold)\1$(tput sgr0)$(tput setaf 3)$(tput bold):$(tput sgr0) \2/g"
}

CMD_NOT_FOUND_HANDLER=''
if hash perl 2>/dev/null && (perl -e "use Text::Levenshtein" 2>/dev/null || \
                   cpan Text::Levenshtein); then
  CMD_NOT_FOUND_HANDLER=use_leven
elif hash python3 2>/dev/null && \
    python3 -c 'import CommandNotFound' 2>/dev/null; then
  CMD_NOT_FOUND_HANDLER=use_cmd_not_found
fi
export CMD_NOT_FOUND_HANDLER

PACKAGE_SEARCH_HANDLER=''
if hash yaourt 2>/dev/null; then
  PACKAGE_SEARCH_HANDLER=use_yaourt
elif hash pacman 2>/dev/null; then
  PACKAGE_SEARCH_HANDLER=use_pacman
elif hash apt-cache 2>/dev/null; then
  PACKAGE_SEARCH_HANDLER=use_apt
fi
export PACKAGE_SEARCH_HANDLER

function truncate_completions {
  cmd="$1"
  echo -e "\033[1;32mcommand '$cmd' not found. \
searching for replacements...\033[1;0m"
  if [ $CMD_ALL ]; then cat
  else "$ZSH_DIR/truncate_completions.pl" "$LEVENSHTEIN_TRUNCATE"
  fi
}

function call_cmd_or_pkg {
  cmd_handler="$1"
  pkg_handler="$2"
  cmd="$3"
  [ $cmd_handler ] && $cmd_handler $cmd
  [ $pkg_handler ] && do_if_internet_route $pkg_handler $cmd
}

if [ $CMD_NOT_FOUND_HANDLER ] || [ $PACKAGE_SEARCH_HANDLER ]; then
  function command_not_found_handler {
    cmd="$1"
    call_cmd_or_pkg "$CMD_NOT_FOUND_HANDLER" "$PACKAGE_SEARCH_HANDLER" \
                    "$cmd" | truncate_completions "$cmd"
  }
fi
