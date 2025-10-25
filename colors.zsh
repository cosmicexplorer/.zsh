declare -g ANSI_COLOR_START="\\033["
declare -g ANSI_COLOR_END_DELIMITER="m"
declare -g ANSI_COLOR_STOP="0"

declare -grA ANSI_KNOWN_COLORS=(
  [black]='0;30'
  [blue]='0;34'
  [green]='0;32'
  [cyan]='0;36'
  [red]='0;31'
  [purple]='0;35'
  [brown]='0;33'
  [light_gray]='0;37'
  [dark_gray]='1;30'
  [light_blue]='1;34'
  [light_green]='1;32'
  [light_cyan]='1;36'
  [light_red]='1;31'
  [light_purple]='1;35'
  [yellow]='1;33'
  [white]='1;37'
)

function lookup-color {
  local -r color_name="$1"
  local -r code="${ANSI_KNOWN_COLORS[$color_name]:-}"
  if [[ -z "$code" ]]; then
    echo "invalid color name ${(q-)color_name}" >&2
    return 1
  fi
  print -r -n "$code"
}

function color-start {
  local -r code="$1"
  if [[ "$code" != [01]';'[0-9][0-9] ]]; then
    echo "internal logic error encoding color code ${(q-)code}" >&2
    return 1
  fi
  printf '%b' \
    "$ANSI_COLOR_START" \
    "$code" \
    "$ANSI_COLOR_END_DELIMITER"
}

function color-end {
  printf '%b' \
    "$ANSI_COLOR_START" \
    "$ANSI_COLOR_STOP" \
    "$ANSI_COLOR_END_DELIMITER"
}

function ensure-trailing-newline {
  sed -e '$a\'
}

declare -rxg format_cat_control='FORMAT_CAT_CONTROL'
function format-cat {
  local -r ctrl_val=${${(P)format_cat_control}:-}
  case "$ctrl_val" in
    ENSURE-TRAILING-NEWLINE)
      ensure-trailing-newline
      ;;
    '')
      cat
      ;;
    *)
      unset "${(P)format_cat_control}"
      yellow "unrecognized value for ${(P)format_cat_control}: ${(q-)ctrl_val}" >&2
      light_gray 'falling back to cat...' >&2
      cat
      ;;
  esac
}

function as-color {
  local -r code="$1"
  # NB: coroutine!
  color-start "$code" \
    && format-cat \
    && color-end
}

function with-color {
  local -r code="$1"
  local -ra text=( "${@:2}" )
  printf '%b' "${(j: :)text[@]}" \
    | as-color "$code"
}

function black {
  with-color "$(lookup-color black)" "$@"
}
function blue {
  with-color "$(lookup-color blue)" "$@"
}
function green {
  with-color "$(lookup-color green)" "$@"
}
function cyan {
  with-color "$(lookup-color cyan)" "$@"
}
function red {
  with-color "$(lookup-color red)" "$@"
}
function purple {
  with-color "$(lookup-color purple)" "$@"
}
function brown {
  with-color "$(lookup-color brown)" "$@"
}
function light_gray {
  with-color "$(lookup-color light_gray)" "$@"
}
function dark_gray {
  with-color "$(lookup-color dark_gray)" "$@"
}
function light_blue {
  with-color "$(lookup-color light_blue)" "$@"
}
function light_green {
  with-color "$(lookup-color light_green)" "$@"
}
function light_cyan {
  with-color "$(lookup-color light_cyan)" "$@"
}
function light_red {
  with-color "$(lookup-color light_red)" "$@"
}
function light_purple {
  with-color "$(lookup-color light_purple)" "$@"
}
function yellow {
  with-color "$(lookup-color yellow)" "$@"
}
function white {
  with-color "$(lookup-color white)" "$@"
}
