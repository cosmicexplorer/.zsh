#;;; -*- mode: sh; sh-shell: zsh -*-

function printfmt {
  printf "$1\n" ${@:2}
}

function err {
  cat $@ >&2
}

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
  fmt="${3:-""$default_print_var_val_fmt""}"
  printf "$fmt" "${varname}" "${val}"
}

function add-newline-if-not {
  sed -e '$a\'
}
function var_log {
  varname="$1"
  print_var_with_val "$varname" "${(P)varname}"
}

function show_vars {
  for arg; do var_log "$arg"; done
}


export DEFAULT_SEP='----\n'
function print_sep {
  echo -n "$DEFAULT_SEP"
}

function sep {
  $@
  print_sep
}

function g {
  grep -nHiP --color=auto --binary-files=without-match $@
}
# recursive
function gr {
  g -R $@ .
}

# ps is cool too
function p {
  ps aux | grep -vP '\bgrep\b' | grep -iP --color=auto --binary-files=without-match $@
}
function ptree {
  ps auxf $@
}
function po {
  ps axo $@
}
function ps-help {
  cat 1>&2 <<EOF
ps [simple-selectors...[=ax]] [list-selectors...] [format...[=u]]

1. simple process selection (e.g. whether on tty)
'ax' => all (default)
'T' => all associated with this terminal
'r' => running processes

2. list process selection
'p <pidlist>' => only pids in list
'-C <cmdlist>' => only from commands (executable names) in list

3. output format
'u' => many columns of data (default)
'o <format>' => only columns specified in <format>

- <format> is a quoted list of:
    1. '<col>' => the identifier of some output column
    2. '<col>=<name>' => the column id and what to rename it to in output

4. output modifiers
'e' => show environment after command
'f' => show results in a tree
'k <[+|-]col,...>' => sort on columns, specifying whether ascending or
descending


5. output columns ('<numeric>=<textual>' are synonyms when listed like that)
'<>=c' => actual command
'rss=<>' => resident set size
'cp=pcpu' => cpu stress
'<>=args' => argv
'time=cputime' => cumulative cpu time
'etimes=etime' => elapsed time since start
'<>=f' => flags
'<>=cls' => scheduling class
'<>=sched' => scheduling policy
'egid=egroup' => process group id (just one for whole tree)
'ruid=ruser' => user id
'<>=stat' => state
'<>=cstime' => cumulative system time
'<>=cutime' => cumulative user time

The above is just a summary; check 'man ps' for complete info! Don't use
a hyphen for args unless specified, not all switches need to you to specify a
value, all lists are either quoted or separated with commas.
EOF
}

function emacs-list-processes {
  ps u -C emacs
}

function emacs-kill-processes {
  ps -C emacs -o pid:1 --no-headers | xargs kill -9
}

# TODO: make this better
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

function path_extend_export {
  local -r varname="$1"
  if [[ ! -d "${(P)varname}" ]]; then
    printfmt "parameter %s does not resolve to a valid directory (PATH=%s)" \
             "$varname" "$PATH" >&2
    return 1
  fi
  export "$varname"
  local bindir="${(P)varname}"
  if [[ -v 2 ]]; then
    bindir="$bindir/$2"
  fi
  if [[ ! -d "$bindir" ]]; then
    printfmt "proposed path extension '%s' does not exist (PATH='%s')" \
             "$bindir" "$PATH" >&2
    return 1
  else
    PATH="$PATH:$bindir"
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

function vomit {
  zsh -xi -c exit 2>&1
}

function k {
  kill -9 $@
}

function b {
  od -t c -Ad -w10
}

function exec-find {
  whence -p $@
}

function null {
  cat /dev/null
}

function valid-ssh-agent-p {
  [[ -v SSH_AUTH_SOCK && -S "$SSH_AUTH_SOCK" ]] && \
    ( [[ -v SSH_AGENT_PID ]] && kill -0 "$SSH_AGENT_PID" 2>/dev/null )
}

export SSHPASS_FILE="$ZSH_DIR/.sshpass"

function make-ssh-agent {
  local -r auth_path="$1"
  ( [[ -f "$auth_path" ]] || ssh-agent -s > "$auth_path" ) && \
    source "$auth_path" >/dev/null
}

function add-ssh {
  local -r auth_path="$1"
  if [[ -f "$auth_path" ]]; then
    export SSH_ASKPASS="$ZSH_DIR/read-ssh-pass.sh"
    DISPLAY=":0" ssh-add <"$auth_path"
  else
    ssh-add
  fi 2>/dev/null
}

export SSH_PW_FILE="$ZSH_DIR/.ssh_pw"

function setup-ssh-agent {
  if valid-ssh-agent-p; then return 0; fi
  if ! exec-find ssh-agent ssh-add >/dev/null; then return 1; fi
  make-ssh-agent "$SSHPASS_FILE"
  if ! valid-ssh-agent-p; then
    rm "$SSHPASS_FILE"
    make-ssh-agent "$SSHPASS_FILE"
  fi
  add-ssh "$SSH_PW_FILE"
}

function silent-on-success {
  local -ra cmd=( "$@" )
  local -r tmpdir="$(mktemp -d)"
  local -r outf="$tmpdir/stdout" errf="$tmpdir/stderr"
  trap "rm -rf $tmpdir" EXIT
  ${cmd} >"$outf" 2>"$errf" || (
    local -r code="$?"
    cat "$outf"
    err "$errf"
    return "$code"
  )
}

# TODO: make a wrapper for zparseopts that generates help text!
function all-found-p {
  local -A opts
  zparseopts -A opts -D -M \
             v -verbose=v \
             h -help=h
  local -ra pos=( "$@" )

  if [[ "${#pos}" -eq 0 || "${#opts[(I)-h]}" -ne 0 ]]; then
    echo "USAGE: all-found-p [ -v ] [ -h ] SPEC...\n" >&2
    echo \
      "Each SPEC is of the format \`name=type'. This function will search" \
      "for an instance of \`name' registered as the given \`type', where" \
      "\`type' corresponds to the output of \`whence -w'." >&2

    return 1
  fi

  for const in $pos; do
    if [[ "$const" =~ ^([^=]+)=([^=]+)$ ]]; then
      local ident="${match[1]}" typespec="${match[2]}"
      local pat="$(printf "^%s:[[:space:]]+%s" "$ident" "$typespec")"
      if ! whence -wa "$ident" | grep -Pq "$pat"; then
        printf "identifier '%s' of type '%s' could not be found\n" \
               "$ident" "$typespec" >&2
        return 1
      fi
    elif [[ "$const" =~ ^([^=]+)=?$ ]]; then
      local ident="${match[1]}"
      if ! whence -wa "$ident" >/dev/null; then
        printf "identifier '%s' could not be found\n" "$ident" >&2
        return 1
      fi
    else
      printf "name/type pair '%s' could not be parsed\n" "$const" >&2
      return 1
    fi
  done

  return 0
}

function shopt {}

function get_battery {
  upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage"
}
