
alias gs="git status"
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


# Set the following in vscode > Settings (UI) > FontFamily
# 'JetBrainsMono Nerd Font Mono'
# Path is a git repository
export FANCYGIT_ICON_GIT_REPO=""

# Only local branch icon.
export FANCYGIT_ICON_LOCAL_BRANCH=""

# Branch icon.
export FANCYGIT_ICON_LOCAL_REMOTE_BRANCH=""

# Merged branch icon.
export FANCYGIT_ICON_MERGED_BRANCH=""

# Staged files.
export FANCYGIT_ICON_HAS_STASHES=" "

# Untracked files.
export FANCYGIT_ICON_HAS_UNTRACKED_FILES=" "

# Changed files.
export FANCYGIT_ICON_HAS_CHANGED_FILES=" "

# Added files.
export FANCYGIT_ICON_HAS_ADDED_FILES=" "

# Unpushed commits.
export FANCYGIT_ICON_HAS_UNPUSHED_COMMITS=" "

# Path is a python virtual environment
export FANCYGIT_ICON_VENV=" "




export FZF_DEFAULT_OPTS="
--preview 'bat --color=always --style=numbers --line-range :500 {}' \
--preview-window=right:60%:wrap \
--bind 'pgup:preview-page-up' \
--bind 'pgdn:preview-page-down' \
--bind 'alt-up:preview-up' \
--bind 'alt-down:preview-down' \
--bind 'alt-u:preview-page-up' \
--bind 'alt-d:preview-page-down'"


rgg() {
  if [ -z "$1" ]; then
    echo "Usage: rgg <search_term> [search_path]"
    return 1
  fi

  local search_term="$1"
  local search_path="${2:-.}"

  rg --no-heading --line-number "$search_term" "$search_path" 2>/dev/null \
    | fzf --delimiter : \
          --preview 'bat --color=always --style=numbers --highlight-line {2} --line-range {2}:+10 {1}' \
          --preview-window=right:60%:wrap \
          --bind 'enter:execute(vim {1} +{2})'
}

alias rgf='rgg'
