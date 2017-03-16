#;;; -*- mode: sh; sh-shell: zsh -*-

source "$ZSH_DIR/functions.zsh"

alias 'l'='ls'
alias 's'='ls'
alias 'sl'='ls'

# because nobody cares
export nohup_out_f='/tmp/nohup.out'
alias 'nohup' 'nohup >>$nohup_out_f'

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
alias 'emacs'='run-emacs'

alias 'ec'='emacsclient -n'

# function str_to_array {
# }

# b=("${(f)$(printf '-e\n%s\n' $a)}");


# the second argument/return value of this function is the globally exported variable "prepend_to_els"
export prepend_tmp_arr=()
function prepend_to_els {
  pre_str="$1"
  prepend_tmp_arr=("${(f)$(printf "${pre_str}\n%s\n" $prepend_tmp_arr)}")
}

export emacsclient_eval_arg='-e'
function ece {
  prepend_tmp_arr=("$@")
  prepend_to_els "${emacsclient_eval_arg}"
  ec $prepend_tmp_arr
}

# TODO: \t

alias 'suvim' 'sudo vim -u $HOME/.vimrc'

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
  # function yaourt {
  #   yaourt --noconfirm $@
  # }
  alias 'yaourt'='yaourt --noconfirm'
fi
