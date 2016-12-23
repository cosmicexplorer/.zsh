#!/bin/zsh

function list_all_cmds {
  print -l ${(k)aliases} ${(k)functions} ${(k)builtins} ${(k)commands}
}

"$ZSH_DIR/use_levenshtein_for_command.pl" "$1" "$LEVENSHTEIN_CMD_DIST" \
                                          <(list_all_cmds)
