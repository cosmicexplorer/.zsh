#;;; -*- mode: sh; sh-shell: zsh -*-

source "$ZSH_DIR/functions.zsh"

alias 'l'='ls'
alias 's'='ls'
alias 'sl'='ls'

# because nobody cares
export nohup_out_f='/tmp/nohup.out'
alias 'nohup'='nohup >>$nohup_out_f'

# start emacs non-windowed, use the snapshot version instead
if "${iswin}"; then
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

alias 'suvim'='sudo vim -u $HOME/.vimrc'

# close R without prompting to save worksprace
alias 'R'='R --no-save'

# sbcl /needs/ readline
if hash rlwrap 2>/dev/null; then
  if hash sbcl 2>/dev/null; then
    alias 'sbcl'='rlwrap sbcl'
  fi
  if hash ocaml 2>/dev/null; then
    alias 'ocaml'='rlwrap ocaml'
  fi
fi

# arch grub doesn't have this
alias 'update-grub'='grub-mkconfig -o /boot/grub/grub.cfg'

# ipython
alias 'ipython_start'='nohup ipython notebook &'

if hash yaourt 2>/dev/null; then
  function y {
    yaourt --noconfirm $@
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
