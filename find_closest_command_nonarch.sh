#!/bin/bash
# bash required for use of compgen (zsh is dumb sometimes)

TRUNCATE_LENGTH=16

stop_truncation="false"

if [ "$2" = "-a" ]; then
  stop_truncation="true"
fi

is_truncated="false"

echo -e -n \
"\033[1;32mcommand $1 not found. searching for replacement...\033[1;0m"

echo "$(compgen -A function -abck | grep "[[:alpha:]]" ; \
        cat ~/.zsh/.aliases | grep alias | \
        grep -v "#" | grep -o " [[:alnum:]]*=" | grep -o "[[:alnum:]]*")" > \
     ~/.zsh/commandNotFoundFile

if [ $stop_truncation = "false" ]; then
  levenshtein_numlines="$(~/.zsh/use_levenshtein_for_command.py $1 | wc -l)"
  ~/.zsh/use_levenshtein_for_command.py $1 | head -n$TRUNCATE_LENGTH
  if [ $levenshtein_numlines -gt $TRUNCATE_LENGTH ]; then
    is_truncated="true"
    echo -e "\033[1;35mand more...\033[1;0m"
  fi
else
  ~/.zsh/use_levenshtein_for_command.py $1
fi

rm ~/.zsh/commandNotFoundFile

if [ $is_truncated = "true" ]; then
  echo -e -n "\033[1;36mmore options are available. "
  echo -e "run with -a to see all.\033[1;0m"
fi
