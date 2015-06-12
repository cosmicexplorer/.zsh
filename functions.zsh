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
  grep-default -r $@ .
}
function find-grep {
  argsWithLast=$(get-last-arg $@)
  findArgs=$(echo $argsWithLast | head -n1)
  grepPattern=$(echo $argsWithLast | tail -n1)
  # string manipulation is hard
  echo $findArgs | tr ' ' '\n' | while read el; do
    echo $el
  done | xargs find | while read line; do
    grep-default $grepPattern "$line"
  done
}
function grep-with-depth {
  find-grep . -maxdepth "$1" -type f "$2"
}
function get-warnings-regex {
  # regex-opt doesn't link correctly on cygwin, and assuming it will necessarily
  # compile and run first time in any environment is probably a poor choice
  # (unless the environment is linux), so this just gives the unoptimized output
  "$ZSH_DIR/find_warnings.pl" "$ZSH_DIR/warning_words" | \
    if [ "$1" = "" ] && "$ZSH_DIR/regex-opt/regex-opt" >/dev/null; then
      # if an argument is provided, then just give the unoptimized as well
      xargs "$ZSH_DIR/regex-opt/regex-opt"
    else
      cat
    fi
}
function find-warnings {
  # shitty hack to check if grep has -P support (it complains about not having
  # perl support with -P, to stdout for some reason, which is why this works)
  if grep -P "" "" 2>&1 | grep "\\-P" >/dev/null; then
    # unfortunately, grep extended doesn't have lookahead or lookbehind, and \w
    # doesn't appear to be working right now (...?), so we also catch the word
    # characters at the beginning and end of the match. we could fix this with
    # an additional grep, but that would disable coloration and i prefer grep's
    # auto coloration, so we'll have to deal with it. your fault for not using a
    # version of grep with pcre support (although grep -E is likely more
    # optimized than -P lol)
    g -E "(^|[^a-zA-Z])($(get-warnings-regex nil))([^a-zA-Z]|$)"
  else                          # but if we do have support, let's optimize
    g -P "(?<!\w)($(get-warnings-regex))(?!\w)"
  fi
}
