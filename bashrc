

alias gad="git add . -A"
alias gci="git commit -m "
alias gciao="git commit --amend --no-edit"
alias gp="git push"

__fzf_cd__() {
  local dir
  dir=$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)
  ) && cd "$dir" && ls -lat
}

bind -x '"\C-f": __fzf_cd__'
