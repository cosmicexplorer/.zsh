#!/bin/zsh

# bash required for compgen (ew)
if ! hash bash; then
  echo "bash not found on this system...I can't do this" 1>&2
  exit -1
fi

ZSH_DIR="${$(dirname "$(readlink -ne "${(%):-%N}")"):A}"

TRUNCATE_LENGTH=16              # must be multiple of two for pacsearch to
# display properly!!!

stop_truncation="false"

if [ "$2" = "-a" ]; then
    stop_truncation="true"
fi

is_truncated="false"

echo -e -n "\033[1;32mcommand $1 not found. \
searching for replacements...\033[1;0m"

echo "$(bash -c "compgen -A function -abck" | grep "[[:alpha:]]" ; \
	cat "$ZSH_DIR/aliases" | grep alias | \
	grep -v "#" | grep -o " [[:alnum:]]*=" | grep -o "[[:alnum:]]*")" > \
"$ZSH_DIR/commandNotFoundFile"

if [ $stop_truncation = "false" ]; then
    levenshtein_lines="$("$ZSH_DIR/use_levenshtein_for_command.py" $1 | wc -l)"
    "$ZSH_DIR/use_levenshtein_for_command.py" $1 | head -n$TRUNCATE_LENGTH
    if [ $levenshtein_lines -gt $TRUNCATE_LENGTH ]; then
        is_truncated="true"
        echo -e "\033[1;35mand more...\033[1;0m"
    fi
else
    "$ZSH_DIR/use_levenshtein_for_command.py" $1
fi

rm "$ZSH_DIR/commandNotFoundFile"

# if internet available
if [ "$(ip route ls)" != "" ] ; then

    if hash yaourt 2>/dev/null; then
        echo -e -n "\033[1;33msearching pacman and AUR...\033[1;0m"
    else
        echo -e -n "\033[1;33msearching pacman...\033[1;0m"
    fi

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
