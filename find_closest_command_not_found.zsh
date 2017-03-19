#!/bin/zsh

# overrideable
export LEVENSHTEIN_CMD_DIST=3
export LEVENSHTEIN_DEFAULT_TRUNC=16
export LEVENSHTEIN_TRUNCATE="$LEVENSHTEIN_DEFAULT_TRUNC"

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

if hash perl 2>/dev/null && (perl -e "use Text::Levenshtein" 2>/dev/null || \
                   cpan Text::Levenshtein); then
  export CMD_NOT_FOUND_HANDLER=use_leven
elif hash python3 2>/dev/null && \
    python3 -c 'import CommandNotFound' 2>/dev/null; then
  export CMD_NOT_FOUND_HANDLER=use_cmd_not_found
fi

if hash yaourt 2>/dev/null; then
  export PACKAGE_SEARCH_HANDLER=use_yaourt
elif hash pacman 2>/dev/null; then
  export PACKAGE_SEARCH_HANDLER=use_pacman
elif hash apt-cache 2>/dev/null; then
  export PACKAGE_SEARCH_HANDLER=use_apt
fi

function get_trunc {
  if [[ "$LEVENSHTEIN_TRUNCATE" =~ '[0-9]+' ]]; then
    echo "$LEVENSHTEIN_TRUNCATE"
  else
    echo "$LEVENSHTEIN_DEFAULT_TRUNC"
  fi
}

# set CMD_ALL to see everything
unset CMD_ALL
function truncate_completions {
  cmd="$1"
  echo -e "\033[1;32mcommand '$cmd' not found. \
searching for replacements...\033[1;0m"
  if [[ -v CMD_ALL ]]; then cat
  else
    trunc="$(get_trunc)"
    sed_cmd='1,'"$trunc"'p'
    more_str="$(echo -e '\033[1;36mand more...\033[1;0m')"
    sed_more="$trunc"" { i \
$more_str
                        q }"
    sed -n -e "$sed_cmd" -e "$sed_more"
  fi
}

function call_handler_if_set {
  handler_varname="$1"
  cmd="$2"
  [[ -v "$handler_varname" ]] && ${=${(P)handler_varname}} "$cmd"
}

function get_cmd_alternatives {
  cmd="$1"
  call_handler_if_set 'CMD_NOT_FOUND_HANDLER' "$cmd"
  call_handler_if_set 'PACKAGE_SEARCH_HANDLER' "$cmd"
  [[ -v CMD_NOT_FOUND_HANDLER ]] && $CMD_NOT_FOUND_HANDLER $cmd
  [[ -v PACKAGE_SEARCH_HANDLER ]] && \
    do_if_internet_route $PACKAGE_SEARCH_HANDLER $cmd
}

function command_not_found_handler {
  cmd="$1"
  get_cmd_alternatives "$cmd" | truncate_completions "$cmd"
}
