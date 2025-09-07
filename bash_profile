# Colors (tmux-safe with \[ \])
red='\[\e[31m\]'
green='\[\e[32m\]'
yellow='\[\e[33m\]'
blue='\[\e[34m\]'
magenta='\[\e[35m\]'
cyan='\[\e[36m\]'
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

    git diff --cached --quiet 2>/dev/null || staged="${green}+${reset}"
    git diff --quiet 2>/dev/null || dirty="${red}*${reset}"
    [ -n "$(git ls-files --others --exclude-standard)" ] && untracked="${blue}?${reset}"

    echo "(${branch}${staged}${dirty}${untracked})"
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
        git_segment=" ${yellow}${git_info}${reset}"
    else
        git_segment=""
    fi

    # Final PS1
    PS1=" ${penguin} ${cyan}\w${reset}${git_segment} ${magenta}➜${reset} "
}

PROMPT_COMMAND=set_bash_prompt

