source "${ZSH_DIR}/functions.zsh"

function get-git-root {
  git rev-parse --show-toplevel
}
