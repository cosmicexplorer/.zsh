#;;; -*- mode: sh; sh-shell: zsh -*-

source "$ZSH_DIR/functions.zsh"

# alias ls cause i always mistype it
alias l='ls'
alias s='ls'
alias sl='ls'

# because nobody cares
alias nohup='nohup >/tmp/nohup.out'

# start emacs non-windowed, use the snapshot version instead
alias e='TERM=xterm-256color emacs -nw'
if $iswin; then
  function run-emacs {
    nohup emacs ${@} &
  }
  alias emacs='run-emacs'
else
  alias emacs='e'
fi
alias emacs-new-window='TERM=xterm-256color emacsclient -nw -c'
alias emacs-new-window-graphical='TERM=xterm-256color nohup emacsclient -c &'
alias enw='emacs-new-window'
alias enwg='emacs-new-window-graphical'
alias ec='TERM=xterm-256color emacsclient -n'
alias suvim="sudo vim -u $HOME/.vimrc"

# close R without prompting to save worksprace
alias R='R --no-save'

# sbcl /needs/ readline
if hash rlwrap 2>/dev/null; then
  alias sbcl='rlwrap sbcl'
elif hash sbcl 2>/dev/null; then
  echo "Consider installing rlwrap so sbcl doesn't suck!"
fi

# arch grub doesn't have this
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'

# ipython
alias ipython_start='nohup ipython notebook &'
