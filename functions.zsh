#;;; -*- mode: sh; sh-shell: zsh -*-

function args-as-lines {
  printf '%s\n' $@
}

function printfmt {
  printf "$1\n" ${@:2}
}

function err {
  if [[ "$#" -ne 0 ]]; then
    echo '# ' $@ >&2
  fi
}

function die {
  err $@
  exit 1
}

function spew {
  cat >&2
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
  grep -nHiE --color=auto --binary-files=without-match $@
}
# recursive
function gr {
  g -R $@ .
}

# ps is cool too
function p {
  ps aux | grep -vE '\bgrep\b' | grep -iE --color=auto --binary-files=without-match $@
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
      if ! whence -wa "$ident" | grep -Eq "$pat"; then
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

function cmd-rc {
  "$@" >&2
  echo "$?"
}

function command-MUST-exist {
  local -r cmd="$1"
  local -r exists="$(cmd-rc command-exists "$cmd")"
  if [[ "$exists" -ne 0 ]]; then
    err "command '$cmd' is REQUIRED for $exists."
    if [[ -v "$exists" ]]; then
      # `which` prints out what the function actually is.
      which "$exists"
    fi
    exit 1
  fi
}

function rlwrap-command-alias {
  local -r subcommand="$1"
  local -ra args=( "${@:2}" )
  if command-exists rlwrap && command-exists "$subcommand"; then
    alias "$subcommand"="rlwrap $subcommand ${args[@]}"
  elif command-exists "$subcommand"; then
    alias "$subcommand"="$subcommand ${args[@]}"
  fi
}

function command-exists-and-not-running {
  command-exists "$1" && process-not-running "$1"
}

function non-darwin-uname-a {
  uname -a | grep -E '^Darwin' >/dev/null
}

function is-osx {
  with-set-x non-darwin-uname-a
}

function with-set-x {
  set -x
  # zsh -i -c "$@"
  "$@"
  set +x
}

function p@ {
  with-set-x \
    ping -c "${1:-3}" "${2:-8.8.8.8}"
}
command-MUST-exist ping p@

declare -gxa PARALLEL_ARGS=( ${PARALLEL_ARGS[@]:-} )
# TODO: This _ARGS / etc configuration should be a generalization like pants options.
function filter {
  # TODO: It would be really nice to be able to add command line arguments to single processes in
  # deeply-nested pipelines, *without* requiring each executable to implement their own set of env
  # vars to control their behavior.
  # *Solution:*
  #   - Allow /individual functions/ to declare config vars/expansion points.
  #     - E.g. This method could have allowed selecting the shell `sh`, or where to point `echo` to.
  #       - /(The above two are horrible examples, since this `filter` operation is expected to be
  #       super low-level)/.
  #   - We can lift up function argument parsing to be the *exact same implementation* as parsing
  #     executables CLIs (with sbang).
  # TODO: hygeinically joining lines!!! Wow!!!!
  local -ra cmd=( "$@" )
  parallel "${PARALLEL_ARGS[@]}" -L1 "( ${cmd[@]} ) && echo >&2 '{}'"
}
command-MUST-exist parallel filter

# TODO: This function isn't useful because (currently) we don't pass down any shell environment to
# `parallel`.
function executable-file-p {
  [[ -f "$1" ]] && [[ -x "$1" ]]
}
# TODO: `@featurep [[ -x ]]` is a *really* nice way of stating whatever works on a shell where the
# builtin `[[...]]` has the `-x` check.

function locate-executable-files {
  local -r executable_filename="$1"
  # TODO: some type-safe way to ensure we've escaped `executable_filename` before injecting it into
  # grep -E!
  # locate "${executable_filename}" \
  #   | grep -E "/${executable_filename}\$" \
  #   | with-set-x filter executable-file-p "${executable_filename}"
  # TODO: `filter executable-file-p` is failing because the `parallel` invocation inside of `filter`
  # can't access the defintion of the shell function!
  # TODO: `env_parallel` exists, but what if we could avoid having a daemon by using `whence -f`??
  # TODO: !!!!!! what if we created a generalized IR between shells among the vein of `whence -f` is a
  # compat adapter between all shells!!!!!!!
  #   - for now, we have a working replacement (an inline function definition with the name 'f'.
  locate "${executable_filename}" \
    | grep -E "/${executable_filename}\$" \
    | filter "[[ -f "$1" ]] && [[ -x "$1" ]] && echo '{}'"
}
command-MUST-exist locate locate-executable-files

function find-executable-files {
  local -r executable_filename="$1"
  local -r d="${2}"
  local -ra find_args=( "${@:3}" )
  find "$d" \
    -iname "$executable_filename" \
    -executable "${find_args[@]}" \
    | filter executable-file-p "${executable_filename}"
}

function extend_path_var {
  local -r varname="$1"
  local -ra new_entries=( "${@:2}" )

  if [[ "${#new_entries[@]}" -eq 0 ]]; then
    local -r entries_string=''
  else
    local -r entries_string="${(j/:/)new_entries[@]}"
  fi
  # This is prefixed with a ':', if non-empty, otherwise no ':' is inserted.
  local -r var_expansion_string="${${${(P)varname}:+:${(P)varname}}:-}"

  echo "${entries_string}${var_expansion_string}"
}
