#!/bin/bash
# bash required for use of compgen

TRUNCATE_LENGTH=16              # must be multiple of two for pacsearch to
				# display properly!!!

stop_truncation="false"

if [ "$#" -eq 2 ]; then
    stop_truncation="true"
    echo "???"
fi

is_truncated="false"

echo -e -n "\033[1;32mcommand not found. searching for replacements...\033[1;0m"

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

echo -e -n "\033[1;33msearching pacman repositories...\033[1;0m"

if [ $stop_truncation = "false" ]; then
    pacsearch_numlines="$(pacsearch $1 | wc -l)"
    if [ $pacsearch_numlines -eq 0 ]; then
       echo -e "\033[1;31mnone found.\033[1;0m"
    else
        echo -n -e "\n"
        pacsearch $1 | head -n$TRUNCATE_LENGTH
        if [ $pacsearch_numlines -gt $TRUNCATE_LENGTH ]; then
            is_truncated="true"
            echo -e "\033[1;33mand more...\033[1;0m"
        fi
        if [ $is_truncated = "true" ]; then
            echo -e -n "\033[1;36mmore options are available. "
            echo -e "run with -a to see all.\033[1;0m"
        fi
    fi
else
        pacsearch $1
fi

rm ~/.zsh/commandNotFoundFile
