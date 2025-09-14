# Colors (tmux-safe with \[ \])
red='\[\e[31m\]'
green='\[\e[32m\]'
yellow='\[\e[33m\]'
blue='\[\e[34m\]'
magenta='\[\e[35m\]'
cyan='\[\e[36;1m\]'   # bold cyan for branch
white='\[\e[37m\]'
reset='\[\e[0m\]'

# Function to get fancy git info
parse_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return

    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Status flags
    staged=""
    dirty=""
    untracked=""
    ahead_behind=""

    git diff --cached --quiet 2>/dev/null || staged="${green}+${reset}"
    git diff --quiet 2>/dev/null || dirty="${red}*${reset}"
    [ -n "$(git ls-files --others --exclude-standard)" ] && untracked="${blue}?${reset}"

    # Ahead/behind check
    remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$remote" ]; then
        ahead=$(git rev-list --count HEAD ^"$remote" 2>/dev/null)
        behind=$(git rev-list --count "$remote" ^HEAD 2>/dev/null)

        [ "$ahead" -gt 0 ] && ahead_behind="${ahead_behind}${green}↑${ahead}${reset}"
        [ "$behind" -gt 0 ] && ahead_behind="${ahead_behind}${red}↓${behind}${reset}"
    fi

    echo "(${cyan}${branch}${reset}${staged}${dirty}${untracked}${ahead_behind})"
}

# Fancy prompt function
set_bash_prompt() {
    exit_code=$?

    # Penguin color based on exit code
    if [ $exit_code -eq 0 ]; then
        penguin="${green}🐧${reset}"
    else
        penguin="${red}🐧${reset}"
    fi

    # Build git segment
    git_info=$(parse_git_branch)
    if [ -n "$git_info" ]; then
        git_segment=" ${git_info}"
    else
        git_segment=""
    fi

    # Final PS1
    PS1=" ${penguin} ${blue}\u${reset}@${green}\h${reset} ${white}\w${reset}${git_segment} ${magenta}➜${reset} "
}

PROMPT_COMMAND=set_bash_prompt

if [ -f "$HOME/.bash_aliases" ]; then
  . $HOME/.bash_aliases 
fi

if [ -f "$HOME/.bash_ssh" ]; then
  . $HOME/.bash_ssh
fi

if [ -f "$HOME/.bash_aliases" ]; then
  . $HOME/.bash_aliases
fi
