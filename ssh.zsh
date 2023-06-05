# This file introduces a lot of intermediate files that aren't really written down. Sorry!

# source "${ZSH_DIR}/functions.zsh"

function valid-ssh-agent-p {
  [[ -v SSH_AUTH_SOCK && -S "$SSH_AUTH_SOCK" ]] && \
    ( [[ -v SSH_AGENT_PID ]] && kill -0 "$SSH_AGENT_PID" 2>/dev/null )
}

export SSHPASS_FILE="$ZSH_DIR/.sshpass"

function make-ssh-agent {
  local -r auth_path="$1"
  ( [[ -f "$auth_path" ]] || ssh-agent -s > "$auth_path" ) && \
    source "$auth_path" >/dev/null
}

function add-ssh {
  local -r auth_path="$1"
  if [[ -f "$auth_path" ]]; then
    export SSH_ASKPASS="$ZSH_DIR/read-ssh-pass.sh"
    DISPLAY=":0" ssh-add <"$auth_path"
  else
    ssh-add
  fi 2>/dev/null
}

export SSH_PW_FILE="$ZSH_DIR/.ssh_pw"

function setup-ssh-agent {
  if valid-ssh-agent-p; then return 0; fi
  if ! exec-find ssh-agent ssh-add >/dev/null; then return 1; fi
  make-ssh-agent "$SSHPASS_FILE"
  if ! valid-ssh-agent-p; then
    rm "$SSHPASS_FILE"
    make-ssh-agent "$SSHPASS_FILE"
  fi
  add-ssh "$SSH_PW_FILE"
}
