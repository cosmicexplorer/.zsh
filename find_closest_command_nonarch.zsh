#!/bin/zsh

# bash required for compgen (ew)
if ! hash bash; then
  echo "bash not found on this system...I can't do this" 1>&2
  exit -1
fi

ZSH_DIR="${$(dirname "$(readlink -ne "${(%):-%N}")"):A}"

TRUNCATE_LENGTH=16

stop_truncation="false"

if [ "$2" = "-a" ]; then
  stop_truncation="true"
fi

is_truncated="false"

echo -e -n \
"\033[1;32mcommand $1 not found. searching for replacement...\033[1;0m"

echo "$(bash -c "compgen -A function -abck" | grep "[[:alpha:]]" ; \
        cat "$ZSH_DIR/aliases" | grep alias | \
        grep -v "#" | grep -o " [[:alnum:]]*=" | grep -o "[[:alnum:]]*")" > \
     "$ZSH_DIR/commandNotFoundFile"

if [ $stop_truncation = "false" ]; then
  levenshtein_numlines="$("$ZSH_DIR/use_levenshtein_for_command.py" $1 | wc -l)"
  "$ZSH_DIR/use_levenshtein_for_command.py" $1 | head -n$TRUNCATE_LENGTH
  if [ $levenshtein_numlines -gt $TRUNCATE_LENGTH ]; then
    is_truncated="true"
    echo -e "\033[1;35mand more...\033[1;0m"
  fi
else
  "$ZSH_DIR/use_levenshtein_for_command.py" $1
fi

rm "$ZSH_DIR/commandNotFoundFile"

if [ $is_truncated = "true" ]; then
  echo -e -n "\033[1;36mmore options are available. "
  echo -e "run with -a to see all.\033[1;0m"
fi
