# source "${ZSH_DIR}/functions.zsh"

function get-git-root {
  git rev-parse --show-toplevel
}

GIT_MERGE_BASE_CALCULATED_AGAINST_REFSPEC='master'

function git-merge-base {
  local -r refspec="${1:-${GIT_MERGE_BASE_CALCULATED_AGAINST_REFSPEC}}"
  git merge-base HEAD "$refspec"
}

function git-pull-quiet {
  GIT_MERGE_VERBOSITY=1 git pull origin master
}

function git-checkout-quiet {
  git checkout --quiet "$@"
}
