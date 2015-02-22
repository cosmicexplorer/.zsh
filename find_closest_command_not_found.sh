#!/bin/bash
# bash required for use of compgen

TRUNCATE_LENGTH=16              # must be multiple of two for pacsearch to
# display properly!!!

stop_truncation="false"

if [ "$2" = "-a" ]; then
    stop_truncation="true"
fi

is_truncated="false"

echo -e -n "\033[1;32mcommand $1 not found. searching for replacements...\033[1;0m"

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

# if internet available
if [ "$(ip route ls)" != "" ] ; then

    echo -e -n "\033[1;33msearching pacman and AUR...\033[1;0m"

    if [ $stop_truncation = "false" ]; then
        if hash yaourt 2>/dev/null; then
            pacsearch_numlines="$(yaourt -Ss $1 | wc -l)"
        else
            pacsearch_numlines="$(pacsearch $1 | wc -l)"
        fi
        if [ $pacsearch_numlines -eq 0 ]; then
            echo -e "\033[1;31mnone found.\033[1;0m"
        else
            echo -n -e "\n"
            if hash yaourt 2>/dev/null; then
                yaourt -Ss --color $1 | head -n$TRUNCATE_LENGTH
            else
                pacsearch $1 | head -n$TRUNCATE_LENGTH
            fi
            if [ $pacsearch_numlines -gt $TRUNCATE_LENGTH ]; then
                is_truncated="true"
                echo -e "\033[1;33mand more...\033[1;0m"
            fi
        fi
    else
        if hash yaourt 2>/dev/null; then
            pacsearch_numlines="$(yaourt -Ss $1 --color | wc -l)"
        else
            pacsearch_numlines="$(pacsearch $1 | wc -l)"
        fi
        if [ $pacsearch_numlines -eq 0 ]; then
            echo -e "\033[1;31mnone found.\033[1;0m"
        else
            echo
            if hash yaourt 2>/dev/null; then
                yaourt -Ss --color $1
            else
                pacsearch $1
            fi
        fi
    fi

fi

if [ $is_truncated = "true" ]; then
  echo -e -n "\033[1;36mmore options are available. "
  echo -e "run with -a to see all.\033[1;0m"
fi
