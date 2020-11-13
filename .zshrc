autoload colors; colors
autoload -Uz compinit; compinit
autoload -Uz promptinit; promptinit
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

### New things I've just learned from `man zshoptions`!
# unsetopt AUTO_CD # Don't cd into a directory if I don't realize a program is actually a dir!
# setopt AUTO_PUSHD # All cd is now pushd!!!
# setopt EQUALS # =gcc becomes "$(which gcc)"!
# setopt NOMATCH
# setopt BAD_PATTERN
# setopt BRACE_CCL
# setopt CASE_GLOB
# setopt CASE_MATCH

### Tab completion

# Force a reload of completion system if nothing matched
# this fixes installing a program and then trying to tab-complete its name
function _force_rehash {
  (( CURRENT == 1 )) && rehash
  return 1
}

# Always use menu completion, and make the colors pretty!
zstyle ':completion:*' menu select yes
zstyle ':completion:*:default' list-colors ''

# Completers to use: rehash, general completion, then various magic stuff and
# spell-checking. Only allow two errors when correcting
zstyle ':completion:*' completer _force_rehash _complete _ignored _match \
       _correct _approximate _prefix
zstyle ':completion:*' max-errors 2

# When looking for matches, first try exact matches, then case-insensiive, then
# partial word completion
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**'

# Turn on caching, which helps with e.g. apt
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_DIR/cache"

# Show titles for completion types and group by type
zstyle ':completion:*:descriptions' format "$fg_bold[black]» %d$reset_color"
zstyle ':completion:*' group-name ''

# Ignore some common useless files
zstyle ':completion:*' ignored-patterns '*?.pyc' '__pycache__'
zstyle ':completion:*:*:rm:*:*' ignored-patterns

# Always do mid-word tab completion
setopt complete_in_word

### History
setopt extended_history hist_no_store hist_ignore_dups hist_expire_dups_first \
       hist_find_no_dups inc_append_history share_history hist_reduce_blanks \
       hist_ignore_space
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000


### Some.. options
setopt autocd beep extendedglob nomatch
unsetopt notify

# Don't count common path separators as word characters
WORDCHARS=${WORDCHARS//[&.;\/]}

# Words cannot express how fucking sweet this is
REPORTTIME=2

### Prompt

# Stolen from @thingskatedid on Twitter, a hack so that you can actually copy/paste terminal output!
export _BASE_PROMPT=';'
# Now extending the idea.
export COMMENT_START='# '

# %(!.☭.⚘)

RPROMPT_code="%(?..\$? %{$fg_no_bold[red]%}%?%{$reset_color%} )"
RPROMPT_jobs="%1(j.%%# %{$fg_no_bold[cyan]%}%j%{$reset_color%} .)"
RPROMPT_time="%{$fg_no_bold[yellow]%}%*%{$reset_color%}"
# export PROMPT="%{%(!.$fg_bold[red].$fg_bold[magenta])%}%n@%m:%{$reset_color%} \
# %{$fg_bold[blue]%}%~%{$reset_color%}${_newline}${_BASE_PROMPT} "
export PROMPT="%{%F{white}%}${COMMENT_START}%{$reset_color%}%{%(!.$fg_bold[red].$fg_bold[magenta])%}%n@%m:%{$reset_color%} \
%{$fg_bold[blue]%}%~%{$reset_color%} $RPROMPT_time $RPROMPT_code$RPROMPT_jobs
%{$fg_bold[cyan]%}${_BASE_PROMPT}%{$reset_color%} "
#☭%(!.☭.>) "

### Misc aliases

export PAGER=less
# Never wrap long lines by default
# I'd love to have the effect of -F, but I don't want -X all the time, alas.
export LESS="-RMi~Kq"

export UNAME_BASE="$(uname -a | cut -b-5)"
if [[ "$UNAME_BASE" = "MINGW" || "$UNAME_BASE" = "CYGWIN" ]]; then
  export WIN="$UNAME_BASE"
fi

# centralize aliases to single file
source "${ZSH_DIR}/aliases.zsh"

source "${ZSH_DIR}/git_wrapper.zsh"
source "${ZSH_DIR}/pants_wrapper.zsh"

source "${ZSH_DIR}/gpg.zsh"
source "${ZSH_DIR}/ssh.zsh"
source "${ZSH_DIR}/x.zsh"


### ls

# long mode, show all, natural sort, type squiggles, friendly sizes
if hash dircolors 2>/dev/null && \
    [[ -v TERM && ! "$TERM" =~ 'dumb|emacs' ]]; then
  eval "$(dircolors -b)"
  LSOPTS='-lAvFh --si --color=always'
  LLOPTS='-lAvFh --color=always'
else
  export CLICOLOR=YES
  LSOPTS='-lAvFh'
  LLOPTS=''
fi

# Just loaded new ls colors via dircolors, so change completion colors
# to match
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# function ls

alias ls="ls $LSOPTS"
alias ll="ls $LLOPTS | less -FX"


### screen

function title {
  # param: title to use

  local prefix=''

  # If I'm in a screen, all the windows are probably on the same machine, so
  # I don't really need to title every single one with the machine name.
  # On the other hand, if I'm not logged in as me (but, e.g., root), I'd
  # certainly like to know that!
  if [[ $USER == 'root' ]]; then
    prefix="[$USER] "
  fi
  # Set screen window title
  if [[ $TERM == "screen"* ]]; then
    print -n "\ek$prefix$1\e\\"
  fi


  # Prefix the xterm title with the current machine name, but only if I'm not
  # on a local machine. This is tricky, because screen won't reliably know
  # whether I'm using SSH right now! So just assume I'm local iff I'm not
  # running over SSH *and* not using screen. Local screens are fairly rare.
  prefix=$HOST
  if [[ "${SSH_CONNECTION:-}" == '' && $TERM != "screen"* ]]; then
    prefix=''
  fi
  # Wrap it in brackets
  if [[ $prefix != '' ]]; then
    prefix="[$prefix] "
  fi

  # Set xterm window title
  if [[ $TERM == "xterm"* || $TERM == "screen"* ]]; then
    print -n "\e]2;$prefix$1\a"
  fi
}

function precmd {
  # Shorten homedir back to '~'
  local shortpwd=${PWD/$HOME/\~}
  title "zsh $shortpwd"
}

function preexec {
  title $*
}


### Keybindings

bindkey -e

# General movement
# Taken from http://wiki.archlinux.org/index.php/Zsh and Ubuntu's inputrc
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, can't hurt for RH/Debian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

# Tab completion
bindkey '^i' complete-word # tab to do menu
bindkey "\e[Z" reverse-menu-complete # shift-tab to reverse menu

# Up/down arrow.
# I want shared history for ^R, but I don't want another shell's activity to
# mess with up/down. This does that.
down-line-or-local-history() {
  zle set-local-history 1
  zle down-line-or-history
  zle set-local-history 0
}
zle -N down-line-or-local-history
up-line-or-local-history() {
  zle set-local-history 1
  zle up-line-or-history
  zle set-local-history 0
}
zle -N up-line-or-local-history

bindkey "\e[A" up-line-or-local-history
bindkey "\eOA" up-line-or-local-history
bindkey "\e[B" down-line-or-local-history
bindkey "\eOB" down-line-or-local-history

export SNIPPETS_DIR="$ZSH_DIR/snippets"
function get_shell_snippets {
  local script
  find "$SNIPPETS_DIR" -type f -name "*.zsh" | \
    while read -r script; do source "$script"; done
}

if [ -d "$SNIPPETS_DIR/.git" ]; then
  pushd "$SNIPPETS_DIR"
  git submodule update --init --recursive && \
    get_shell_snippets
  popd
fi

set +o histexpand
