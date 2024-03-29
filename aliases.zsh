# source "${ZSH_DIR}/functions.zsh"

# HAHAHAHAHAHAHAHAHAAHAHAHAGH
function cd {
  pushd "$@" >&2
}

alias 'l'='ls'
alias 's'='ls'
alias 'sl'='ls'

# because nobody cares
export nohup_out_f='/tmp/nohup.out'
alias 'nohup'='nohup >>$nohup_out_f'

# start emacs non-windowed, use the snapshot version instead
if [[ -v WIN ]]; then
  function run-emacs {
    nohup emacs ${@} &
  }
else
  function run-emacs {
    ${${TERM:?}+}
    emacsclient -c -nw -a '' $@
  }
fi

function ec {
  emacsclient -n $@
}

# NOTE: this function is so so nice
function ecr {
  (
    with-fifo 'cat' 'add-newline-if-not' && \
      emacsclient -e \
       "(load \"$ZSH_DIR/read-pipe.el\")" \
       "(read-from-pipe \"${WITH_FIFO_OUT_QUEUES[1]}\")" \
       >/dev/null 2>"${WITH_FIFO_IN_QUEUES[2]}" &

    cat <"${WITH_FIFO_OUT_QUEUES[2]}" >&2 &
    >"${WITH_FIFO_IN_QUEUES[1]}"
  )
}

# was used for "ece", but unneeded
# prepend_tmp_arr is the argument and return value of prepend_to_els()
export prepend_tmp_arr=()
function prepend_to_els {
  pre_str="$1"
  prepend_tmp_arr=("${(f)$(printf "${pre_str}\n%s\n" $prepend_tmp_arr)}")
}

function ece {
  emacsclient -e $@
}

alias el='emacs-list-processes'
alias ek='emacs-kill-processes'

# TODO: \t

alias 'suvim'='sudo vim -u $HOME/.vimrc --cmd "set runtimepath=$HOME/.vim"'

# close R without prompting to save worksprace
rlwrap-command-alias R --no-save

# sbcl /needs/ readline
rlwrap-command-alias sbcl
rlwrap-command-alias ocaml

# arch grub doesn't have this
alias 'update-grub'='grub-mkconfig -o /boot/grub/grub.cfg'

# ipython
alias 'ipython_start'='nohup ipython notebook &'

if hash yay 2>/dev/null; then
  function y {
    # If the command isn't a '-S' one, don't add the --overwrite flag.
    if (($@[(I)-S*])); then
      yay --noconfirm --overwrite '*' $@
    else
      yay --noconfirm $@
    fi
  }
fi

if hash pass 2>/dev/null; then
  function pw {
    if [[ "$#" -eq 0 ]]; then
      echo "USAGE: pw PASS-NAME [ARGS...]" >&2
      return -1
    fi
    pass insert ${@:2} "$1" && pass show "$1"
  }
fi

export GH_USERNAME='cosmicexplorer'
function gh-ssh {
  local -r repo="$1"
  local -ra rest=("${@:2}")
  git clone "git@github.com:${GH_USERNAME}/${repo}" "${rest[@]}"
}

alias gb='git branch'
