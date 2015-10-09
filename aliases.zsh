#;;; -*- mode: sh; sh-shell: zsh -*-

source "$ZSH_DIR/functions.zsh"

# alias ls cause i always mistype it
alias l='ls'
alias s='ls'
alias sl='ls'

# because nobody cares
alias nohup='nohup >>/tmp/nohup.out'

# start emacs non-windowed, use the snapshot version instead
if $iswin; then
  function run-emacs {
    nohup emacs ${@} &
  }
  alias emacs='run-emacs'
else
  alias emacs='TERM=xterm-256color emacsclient -c -nw -a ""'
fi
alias ec='emacsclient -n'
alias suvim="sudo vim -u $HOME/.vimrc"

# close R without prompting to save worksprace
alias R='R --no-save'

# sbcl /needs/ readline
if hash rlwrap 2>/dev/null; then
  if hash sbcl 2>/dev/null; then
    alias sbcl='rlwrap sbcl'
  fi
  if hash ocaml 2>/dev/null; then
    alias ocaml='rlwrap ocaml'
  fi
fi

# arch grub doesn't have this
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'

# ipython
alias ipython_start='nohup ipython notebook &'
