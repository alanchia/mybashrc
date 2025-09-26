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

    # Conda environment segment (show only when active)
    if [ -n "${CONDA_DEFAULT_ENV:-}" ]; then
        conda_segment=" ${yellow}(${CONDA_DEFAULT_ENV})${reset}"
    else
        conda_segment=""
    fi

    # Final PS1
    PS1=" ${penguin} ${blue}\u${reset}@${green}\h${reset}${conda_segment} ${white}\w${reset}${git_segment} ${magenta}➜${reset} "
}

PROMPT_COMMAND=set_bash_prompt

# if [ -f "$HOME/.bash_ssh" ]; then
#   . $HOME/.bash_ssh
# fi

if [ -f "$HOME/.bash_aliases" ]; then
  . $HOME/.bash_aliases
fi

# Always resync SSH_AUTH_SOCK from tmux if inside a tmux session

# Check if we are currently inside a tmux session.
# The environment variable $TMUX is automatically set by tmux when you attach.
if [ -n "$TMUX" ]; then

    # Ask tmux what it thinks SSH_AUTH_SOCK is in its global environment.
    # "tmux show-environment -g SSH_AUTH_SOCK" prints something like:
    #   SSH_AUTH_SOCK=/tmp/ssh-XXXXabcd/agent.12345
    #
    # The `cut -d= -f2` removes the "SSH_AUTH_SOCK=" prefix,
    # leaving only the socket path (/tmp/ssh-XXXXabcd/agent.12345).
    #
    # `2>/dev/null` hides errors in case tmux doesn’t have SSH_AUTH_SOCK set.
    NEW_SOCK="$(tmux show-environment -g SSH_AUTH_SOCK 2>/dev/null | cut -d= -f2)"

    # Make sure NEW_SOCK is valid before using it.
    # -n "$NEW_SOCK"   → check the variable isn’t empty.
    # -S "$NEW_SOCK"   → check that the path points to a socket file that actually exists.
    if [ -n "$NEW_SOCK" ] && [ -S "$NEW_SOCK" ]; then

        # Update the current shell’s SSH_AUTH_SOCK to the new value.
        # This ensures that ssh, ssh-add, git, etc. will talk to the correct agent.
        export SSH_AUTH_SOCK="$NEW_SOCK"
    fi
fi

# Fix SSH agent even outside tmux (for VS Code or direct shells)
if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
    NEW_SOCK=$(find /tmp/ssh-* -type s -user "$USER" 2>/dev/null | head -n 1)
    if [ -n "$NEW_SOCK" ] && [ -S "$NEW_SOCK" ]; then
        export SSH_AUTH_SOCK="$NEW_SOCK"
    fi
fi