#;;; -*- mode: sh; sh-shell: zsh -*-

function get-last-arg {
  lastArg=""
  prevArgs=""
  for arg in $@; do
    prevArgs="$prevArgs $lastArg"
    lastArg="$arg"
  done
  echo "$(echo $prevArgs | cut -b3-)\n$lastArg"
}

# grep is da bomb
function grep-default {
  grep -nH --color --binary-files=without-match $@
}
function g {
  grep-default -r $@
}
function find-grep {
  argsWithLast=$(get-last-arg $@)
  findArgs=$(echo $argsWithLast | head -n1)
  grepPattern=$(echo $argsWithLast | tail -n1)
  echo $findArgs | tr ' ' '\n' | while read el; do
    echo $el
  done | xargs find | while read line; do
    grep-default $grepPattern "$line"
  done
}
function grep-with-depth {
  find-grep . -maxdepth "$1" -type f "$2"
}
function get_warnings_regex {
  "$ZSH_DIR/find_warnings.pl" "$ZSH_DIR/warning_words" | \
    xargs "$ZSH_DIR/regex-opt/regex-opt"
}
function find_warnings {
  g -P "(?<!\w)($(get_warnings_regex))(?!\w)"
}
