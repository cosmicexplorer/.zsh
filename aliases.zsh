#;;; -*- mode: sh; sh-shell: zsh -*-

source "$ZSH_DIR/functions.zsh"

# g_alias ls cause i always mistype it
g_alias 'l' 'ls'
g_alias 's' 'ls'
g_alias 'sl' 'ls'

# because nobody cares
export nohup_out_f='/tmp/nohup.out'
g_alias 'nohup' "nohup >>$nohup_out_f"

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
g_alias 'emacs' 'run-emacs'

function ec {
  emacsclient -n $@
}

function ece {
  ec -e "$1"
}

# TODO: \t

g_alias 'suvim' "sudo vim -u $HOME/.vimrc"

# close R without prompting to save worksprace
g_alias 'R' 'R --no-save'

# sbcl /needs/ readline
if hash rlwrap 2>/dev/null; then
  if hash sbcl 2>/dev/null; then
    g_alias 'sbcl' 'rlwrap sbcl'
  fi
  if hash ocaml 2>/dev/null; then
    g_alias 'ocaml' 'rlwrap ocaml'
  fi
fi

# arch grub doesn't have this
g_alias 'update-grub' 'grub-mkconfig -o /boot/grub/grub.cfg'

# ipython
g_alias "ipython_start" 'nohup ipython notebook &'

if hash yaourt 2>/dev/null; then
  g_alias 'yaourt' 'yaourt --noconfirm'
fi
