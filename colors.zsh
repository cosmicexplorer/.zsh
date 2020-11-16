declare -g ANSI_COLOR_START="\\033["
declare -g ANSI_COLOR_END_DELIMITER="m"
declare -g ANSI_COLOR_STOP="0"

declare -gA ANSI_KNOWN_COLORS=(
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

function color-start {
  local -r color_name="$1"
  local -r color_code="$ANSI_KNOWN_COLORS[$color_name]"
  printf '%b' \
    "$ANSI_COLOR_START" \
    "$color_code" \
    "$ANSI_COLOR_END_DELIMITER"
}

function color-end {
  printf '%b' \
    "$ANSI_COLOR_START" \
    "$ANSI_COLOR_STOP" \
    "$ANSI_COLOR_END_DELIMITER"
}

function with-color {
  local -r color_name="$1"
  local -ra text=( "${@:2}" )
  color-start "$color_name"
  printf '%b' "${(j: :)text[@]}"
  color-end
}

function black {
  with-color 'black' "$@"
}
function blue {
  with-color 'blue' "$@"
}
function green {
  with-color 'green' "$@"
}
function cyan {
  with-color 'cyan' "$@"
}
function red {
  with-color 'red' "$@"
}
function purple {
  with-color 'purple' "$@"
}
function brown {
  with-color 'brown' "$@"
}
function light_gray {
  with-color 'light_gray' "$@"
}
function dark_gray {
  with-color 'dark_gray' "$@"
}
function light_blue {
  with-color 'light_blue' "$@"
}
function light_green {
  with-color 'light_green' "$@"
}
function light_cyan {
  with-color 'light_cyan' "$@"
}
function light_red {
  with-color 'light_red' "$@"
}
function light_purple {
  with-color 'light_purple' "$@"
}
function yellow {
  with-color 'yellow' "$@"
}
function white {
  with-color 'white' "$@"
}
