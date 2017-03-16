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

export default_print_var_val_fmt="'\$%s'=>'%s'\n"

function print_var_with_val {
  varname="$1"
  val="$2"
  fmt="${3:-"$default_print_var_val_fmt"}"
  printf "$fmt" "${varname}" "${val}"
}

function var_log {
  varname="$1"
  print_var_with_val "$varname" "${(P)varname}"
}

function show_args {
  print_var_val '#'
  for arg; do print_var_val "$arg"; done
}
function exp {
    echo "${(e)${1}}"
}
function split_args {
  "$1" "${=@:2}"
}

default_sep='----\n'
function print_sep {
  echo -n "$default_sep"
}
function sep {
  $@
  print_sep
}

# grep is da bomb
export MY_GREP_OPTS='-nHiP --color=always --binary-files=text'
function grep-default {
  grep ${=MY_GREP_OPTS} $@
}
function grec {
  grep-default -R $@ .
}
function g {
  grep-default $@
}

# function find-grep {
#   find
# }

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
  # hack to check if grep has -P support (it complains about not having
  # perl support with -P, to stdout for some reason, which is why this works)
  if grep -P "" "" 2>&1 | grep "\\-P" >/dev/null; then
    # unfortunately, grep extended doesn't have lookahead or lookbehind, so we
    # also catch the word characters at the beginning and end of the match. we
    # could fix this with an additional grep, but that would disable coloration
    # and i prefer grep's auto coloration, so we'll have to deal with it. your
    # fault for not using a version of grep with pcre support (although grep -E
    # is likely more optimized than -P lol)
    g -E "(^|[^a-zA-Z])($(get-warnings-regex nil))([^a-zA-Z]|$)"
  else                          # but if we do have support, let's optimize
    g -P "(?<!\w)($(get-warnings-regex))(?!\w)"
  fi
}

function add_path_before_if {
  for arg in $@; do
    [ -d "$arg" ] && PATH="$arg:$PATH"
  done
}

function add_path_if {
  for arg in $@; do
    [ -d "$arg" ] && PATH="$PATH:$arg"
  done
}

function bye {
  $@ && exit
}

function goodread {
  read -r $@
}

function g_alias {
  # res="$1=${@:2}"
  alias -g "${(q)1}"="${(q)2}"
}

function vomit {
  zsh -xi -c exit 2>&1
}
