#!/bin/bash
# bash required for use of compgen

echo "$(compgen -A function -abck ; cat ~/.zsh/.aliases | grep alias |\
	grep -v "#" | grep -o " [[:alnum:]]*=" | grep -o "[[:alnum:]]*")" >\
	 ~/.zsh/commandNotFoundFile

echo -e -n "\033[1;33mcommand not found. searching for replacement commands..."

~/.zsh/use_levenshtein_for_command.py $1 # assumes $1 is command given

rm ~/.zsh/commandNotFoundFile
