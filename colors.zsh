declare -rg ANSI_COLOR_START="\\033["
declare -rg ANSI_COLOR_END_DELIMITER="m"
declare -rg ANSI_COLOR_STOP="0"

declare -rgA ANSI_KNOWN_COLORS=(
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

function with-color {
  local -r color_name="$1"
  local -r text="$2"
  local -r color_code="$ANSI_KNOWN_COLORS[$color_name]"
  local -r encoded_text="$(printf '%s' \
    "$ANSI_COLOR_START" \
    "$color_code" \
    "$ANSI_COLOR_END_DELIMITER" \
    "$text" \
    "$ANSI_COLOR_START" \
    "$ANSI_COLOR_STOP" \
    "$ANSI_COLOR_END_DELIMITER")"
  echo -n "$encoded_text"
}

function black {
  with-color 'black' "$1"
}
function blue {
  with-color 'blue' "$1"
}
function green {
  with-color 'green' "$1"
}
function cyan {
  with-color 'cyan' "$1"
}
function red {
  with-color 'red' "$1"
}
function purple {
  with-color 'purple' "$1"
}
function brown {
  with-color 'brown' "$1"
}
function light_gray {
  with-color 'light_gray' "$1"
}
function dark_gray {
  with-color 'dark_gray' "$1"
}
function light_blue {
  with-color 'light_blue' "$1"
}
function light_green {
  with-color 'light_green' "$1"
}
function light_cyan {
  with-color 'light_cyan' "$1"
}
function light_red {
  with-color 'light_red' "$1"
}
function light_purple {
  with-color 'light_purple' "$1"
}
function yellow {
  with-color 'yellow' "$1"
}
function white {
  with-color 'white' "$1"
}
