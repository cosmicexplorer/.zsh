#;;; -*- mode: sh; sh-shell: zsh -*-

function args-as-lines {
  printf '%s\n' $@
}

function printfmt {
  printf "$1\n" ${@:2}
}

function err {
  cat $@ >&2
}

function die {
  err $@
  exit 1
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

function export_var_if_new_dir {
  local -r dir_path="$1" var_name="$2"

  if [[ -v "$var_name" ]]; then
    warn-here <<EOF
env var '${var_name}' is already defined!
prev: '${(P)var_name}', attempted: '${dir_path}'
EOF
    return 0
  fi

  if [[ -d "$dir_path" ]]; then
    export "${var_name}=${dir_path}"
  else
    warn-here <<EOF
attempted value '${dir_path}' for var '${var_name}' is not a directory!
EOF
    return 0
  fi
}

function export_var_extend_bin_if {
  local -r dir_path="$1" var_name="$2"

  export_var_if_new_dir "$dir_path" "$var_name"

  local -r bin_dir="${dir_path}/bin"
  if [[ -d "$bin_dir" ]]; then
    export PATH="${PATH}:${bin_dir}"
  fi
}

function add_path_before_if {
  for arg; do
    [[ -d "$arg" ]] && PATH="$arg:$PATH"
  done
}

function add_path_if {
  for arg; do
    [[ -d "$arg" ]] && PATH="$PATH:$arg"
  done
}

function warn {
  if [[ -v WARNINGS_ON ]]; then
    echo >&2 "$@"
  fi
}

function warn-here {
  if [[ -v WARNINGS_ON ]]; then
    cat >&2
  fi
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

function has-exec {
  whence -p $@ >/dev/null
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

function get-that-battery-tho {
  upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage"
}

function with-pushd {
  local -r dir="$1"
  local -a argv=("${@:2}")

  pushd "$dir" \
    && "${argv[@]}" \
    && popd
}

# Convert line-delimited output into a :-delimited path (e.g. for PATH or JVM classpaths).
function merge_jars() {
  tr '\n' ':' | sed -re 's#:$##g'
}

function zlib-decompress {
  perl -MCompress::Zlib -e 'undef $/; print uncompress(<>)'
}

function intersect-files {
  diff --old-line-format= --new-line-format= --unchanged-line-format='%L' "$@"
}

function as-editable-script {
  local -r script="$1"
  local -a rest=( "${@:2}" )

  local -r tmp_script="$(mktemp)"
  trap 'rm -fv "$tmp_script"' EXIT

  cp -v "$script" "$tmp_script"
  chmod u+x "$tmp_script"
  "$tmp_script" "$rest[@]"
}

function go {
  pushd "$1" \
    && trap 'popd' EXIT \
    && "${@:2}"
}

function with-file-on-path-as {
  local -r exe="$1"
  local -r desired_exe_name="$2"
  local -ra cmd=( "${@:3}" )

  local -r tmp_path_entry="$(mktemp -d)"
  trap 'rm -fv "$tmp_path_entry"' EXIT

  cp -v "$exe" "${tmp_path_entry}/${desired_exe_name}"
  PATH="${tmp_path_entry}:${PATH}" "$cmd[@]"
}

function kk {
  p "$@" | awk '{print $2}' | parallel -t kill -9
}

function kk-root {
  p "$@" | awk '{print $2}' | parallel -t sudo kill -9
}

function c {
  curl -L --fail "$@"
}

function git-fast-status {
  time PAGER=cat git diff --name-only
}

function process-not-running {
  [[ "$(p "$1" | wc -l)" -lt 1 ]]
}

function command-exists {
  hash "$1" 2>/dev/null
}

function command-exists-and-not-running {
  command-exists "$1" && process-not-running "$1"
}

function is-osx {
  uname -a | grep -P '^Darwin' >/dev/null
}
