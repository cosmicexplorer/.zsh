# source "${ZSH_DIR}/functions.zsh"
# source "${ZSH_DIR}/git-wrapper.zsh"

function with-pants-root {
  local -a argv=("$@")
  local -r git_root="$(get-git-root)"
  with-pushd "$git_root" \
             "${argv[@]}"
}


function get-pants-procs {
  ps aux | grep pants | sed -re 's#^[^0-9]+([0-9]+)[^0-9].*$#\1#g'
}


function kill-all-pants {
  set +x
  get-pants-procs | xargs kill -9
  with-pants-root \
    rm -rfv .pids/ .pants.workdir.file_lock*
  set -x
}
