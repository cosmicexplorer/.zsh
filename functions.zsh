# source "${ZSH_DIR}/colors.zsh"

function args-as-lines {
  printf '%s\n' "$@"
}

function printfmt {
  printf "$1\n" "${@:2}"
}

declare -rxg WARNING_STREAM='-'

function warning-stream {
  if [[ "$WARNING_STREAM" == '-' ]]; then
    cat >&2
  elif [[ -w "$WARNING_STREAM" ]]; then
    cat >>"$WARNING_STREAM"
  else
    die "unrecognized warning stream '${WARNING_STREAM}'"
  fi
}

# FIXME: make this readonly by only sourcing this file one time!
declare -rxg ERR_PREFIX='!'

function err {
  # Print a single newline to the error stream.
  (
    echo
    if [[ "$#" -eq 0 ]]; then
      red "$ERR_PREFIX" "<UNSPECIFIED ERROR>" '\n'
    else
      # Print the prefix, then all of the args.
      red "$ERR_PREFIX" "$@" '\n'
    fi
  ) \
    | warning-stream
}

function die {
  err $@
  return 1
}

# FIXME: make this readonly by only sourcing this file one time!
declare -rxg DEFAULT_PRINT_VAR_VAL_FMT="%s => %s"

function print-var-with-val {
  local -r varname="$1" val="$2" fmt="${3:-${DEFAULT_PRINT_VAR_VAL_FMT}}"
  printf "$fmt" "${(q-)varname}" "${(q-)val}"
}

function var-log {
  local -r varname="$1"
  print-var-with-val "$varname" "${(P)varname}" \
    | format-cat
}

function show-vars {
  for arg; do var-log "$arg"; done
}

declare -rxg DEFAULT_RECORD_SEPARATOR='--------------------\n'
function print-sep {
  echo -n "$DEFAULT_RECORD_SEPARATOR"
}

function sep {
  "$@"
  print-sep
}

function g {
  grep -nHiE --color=auto --binary-files=without-match $@
}
# recursive
function gr {
  g -R "$@" .
}

# ps is cool too
function p {
  ps aux | grep -vE '\bgrep\b' | grep -iE --color=auto --binary-files=without-match "$@"
}
function ptree {
  ps auxf "$@"
}
function po {
  ps axo "$@"
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

function export-var-if-new-dir {
  local -r dir_path="$1" var_name="$2"

  if [[ -v "$var_name" ]]; then
    warning-stream <<EOF
env var '${var_name}' is already defined!
prev: '${(P)var_name}', attempted: '${dir_path}'
EOF
    return 0
  fi

  if [[ -d "$dir_path" ]]; then
    export "${var_name}=${dir_path}"
  else
    warning-stream <<EOF
attempted value '${dir_path}' for var '${var_name}' is not a directory!
EOF
    return 0
  fi
}

function repeat-string {
  local -r base="$1"
  local extent="$2"
  local ret=''
  for _ in $(seq "$extent"); do
    ret+="$base"
    echo "$ret"
  done
  echo "$ret"
}

function export-var-extend-bin-if {
  local -r dir_path="$1" var_name="$2"

  export-var-if-new-dir "$dir_path" "$var_name"

  local -r bin_dir="${dir_path}/bin"
  add-path-if "$bin_dir"
}

function add-path-before-if {
  for arg; do
    if [[ -d "$arg" ]]; then
      path=("$arg" "${path[@]}")
    fi
  done
}

function add-path-if {
  for arg; do
    [[ -d "$arg" ]] && path+="$arg"
  done
}

declare -x WARNINGS_ON

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
  "${cmd[@]}" >"$outf" 2>"$errf" || (
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

function go-try-this {
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
  PATH="${tmp_path_entry}:${PATH}" "${cmd[@]}"
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
  if ! command-exists "$cmd"; then
    die "command '$cmd' is REQUIRED!"
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
  # TODO: !!!!!! what if we created a generalized IR between shells among the vein of `whence -f` is
  # a compat adapter between all shells!!!!!!!
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

function into-clipboard {
  xclip -i -selection clipboard
}
command-MUST-exist xclip

function lookup-color-default {
  local -r varname=$1 default=$2
  local -r resolved_name=${(P)varname:-$default}
  lookup-color "$resolved_name"
}

declare -gxrA var_color_lookup=(
  [VAR_COLOR]=light_gray
  [VAL_COLOR]=white
)

function lookup-var-decl-color {
  local -a ret=( )
  for env_key default in ${(kv)var_color_lookup[@]}; do
    ret+="$(lookup-color-default "$env_key" "$default")"
  done
  printf '%s\n' "${ret[@]}"
}

function attempt-var-decl {
  setopt local_options
  set -uo pipefail

  local -r varname=$1 value=$2
  local -ra eval_cmd=( "${@:3}" )
  local -ra colors=( $(lookup-var-decl-color) )

  declare -gx ${varname}="${value}"
  printf '%s => ' "$varname" | as-color "${colors[1]}"
  if "${eval_cmd[@]}" "$value" | as-color "${colors[2]}"; then
    declare -r ${varname}
  else
    local -r -i 10 rc=$?
    unset ${varname}
    return $rc
  fi
}

function evaluate-python {
  setopt local_options
  set -euo pipefail

  local -r py=$1
  if [[ ! -x "$py" ]]; then
    err "no executable was found at ${(q-)py}"
    return 1
  fi

  if ! "$py" -VV; then
    local -r -i 10 rc=$?
    err "executable at ${(q-)py} was not a standard python"
    return $rc
  fi \
    | sed -re 's#^Python\s+([^\(]+)\s+\((([^:,]+),|.*?:([^,]+),).*$#@\1 (\3\4)#' \
    | sed -e 's#\s*free-threading build#[+free]#'
}

function python-var {
  local -r varname=$1 value=$2
  attempt-var-decl "$varname" "$value" evaluate-python
}

function clean-remote-url {
  sed -r \
      -e 's#^https?://[^/]+/?(.*)$#\1#' \
      -e 's#^[^@]+@[^:]+:(.*)$#\1#'
}

function evaluate-spack-checkout {
  setopt local_options
  set -uo pipefail

  local -r sp=$1
  if [[ ! -d "$sp" ]]; then
    err "no directory was found at ${(q-)sp}"
    return 1
  fi

  local -r sbang="${sp}/bin/sbang"
  if [[ ! -x "$sbang" ]]; then
    err "no sbang wrapper script was found at ${(q-)sbang}"
    return 1
  fi

  local rel="$sp"
  if [[ -v SPACK_CHECKOUT_BASE_DIR ]]; then
    if [[ ! -d "$SPACK_CHECKOUT_BASE_DIR" ]]; then
      err "environment variable \$SPACK_CHECKOUT_BASE_DIR=${SPACK_CHECKOUT_BASE_DIR} did not point to a directory path"
      return 1
    fi
    rel=$(realpath --logical --canonicalize-existing --relative-to "$SPACK_CHECKOUT_BASE_DIR" \
                   "$sp")
  fi
  local -r base_ref=${SPACK_CHECKOUT_BASE_REF:-develop}
  if pushd "$sp" >/dev/null; then
    local -r checksum=$(git rev-parse --short=6 HEAD)
    local -r -i 10 since_develop=$(git rev-list --count "${base_ref}..")
    local -r push_remote=$(git remote get-url --push origin | clean-remote-url)

    local -r purple_fmt=$(lookup-color purple)
    local -r yellow_fmt=$(lookup-color yellow)

    printf '>> %s [@%s = %s+%d]' \
           "$push_remote" \
           "$checksum" \
           "$base_ref" "$since_develop"
    color-start "$yellow_fmt"
    printf ' @ '
    color-start "$purple_fmt"
    printf '%s\n' "${(q-)rel}"

    [[ -v SPACK_PYTHON ]] && declare +r SPACK_PYTHON
    . share/spack/setup-env.sh
    local -r -i 10 rc=$?
    [[ -v SPACK_PYTHON ]] && declare -r SPACK_PYTHON
    popd >/dev/null

    if [[ $rc -ne 0 ]]; then
      err "failed to activate spack environment in ${(q-)sp}"
      return $rc
    elif [[ -v SPACK_PYTHON ]]; then
      declare -gx SPACK_PYTHON
    fi
  fi | ensure-trailing-newline
}

function spack-checkout-var {
  local -r varname=$1 value=$2
  attempt-var-decl "$varname" "$value" evaluate-spack-checkout
}
