# Modern Fish Shell Configuration
# Optimized for development with beautiful prompts and useful functions

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Editor preferences
set -gx EDITOR vim
set -gx VISUAL code

# Language and locale
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Colors for ls and completion
set -gx CLICOLOR 1
set -gx LSCOLORS ExFxBxDxCxegedabagacad

# Development environment
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

# Homebrew paths (Apple Silicon Macs)
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
end

# Homebrew paths (Intel Macs)
if test -d /usr/local/bin
    fish_add_path /usr/local/bin
    fish_add_path /usr/local/sbin
end

# User local bin
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# User bin
if test -d $HOME/bin
    fish_add_path $HOME/bin
end

# Development tools
if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

if test -d $HOME/go/bin
    fish_add_path $HOME/go/bin
end

# Node.js (if using volta or nvm)
if test -d $HOME/.volta/bin
    fish_add_path $HOME/.volta/bin
end

# ============================================================================
# ALIASES
# ============================================================================

# Enhanced ls with exa if available, fallback to ls
if command -v exa >/dev/null
    alias ls='exa --group-directories-first --icons'
    alias ll='exa -l --group-directories-first --icons --git'
    alias la='exa -la --group-directories-first --icons --git'
    alias tree='exa --tree --icons'
    alias lt='exa -l --sort=modified --reverse --icons'
else
    alias ls='ls -G --color=auto'
    alias ll='ls -lhF'
    alias la='ls -lahF'
    alias lt='ls -laht'
end

# Better cat with bat if available
if command -v bat >/dev/null
    alias cat='bat --style=auto'
    alias less='bat --style=auto --paging=always'
end

# Better grep with ripgrep if available
if command -v rg >/dev/null
    alias grep='rg'
else
    alias grep='grep --color=auto'
end

# Better find with fd if available
if command -v fd >/dev/null
    alias find='fd'
end

# Better top with htop if available
if command -v htop >/dev/null
    alias top='htop'
end

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph'
alias gll='git log --oneline --graph --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git rebase'
alias gst='git stash'
alias gsp='git stash pop'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# Quick commands
alias c='clear'
alias h='history'
alias q='exit'
alias e='$EDITOR'
alias v='$VISUAL'

# System information
alias sysinfo='neofetch'
alias diskinfo='df -h'
alias meminfo='free -h'

# Network
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# Fun commands
alias weather='curl wttr.in'
alias moon='curl wttr.in/Moon'
alias starwars='telnet towel.blinkenlights.nl'

# macOS specific
if test (uname) = Darwin
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false; killall Finder'
    alias spotoff='sudo mdutil -a -i off'
    alias spoton='sudo mdutil -a -i on'
end

# ============================================================================
# FUNCTIONS
# ============================================================================

# Create directory and cd into it
function mkcd
    if test (count $argv) -ne 1
        echo "Usage: mkcd <directory>"
        return 1
    end
    mkdir -p $argv[1] && cd $argv[1]
end

# Quick backup function
function backup
    if test (count $argv) -ne 1
        echo "Usage: backup <file>"
        return 1
    end
    cp $argv[1] $argv[1].bak
    echo "Backup created: $argv[1].bak"
end

# Extract various archive formats
function extract
    if test (count $argv) -ne 1
        echo "Usage: extract <archive>"
        return 1
    end

    if not test -f $argv[1]
        echo "Error: '$argv[1]' is not a valid file"
        return 1
    end

    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz' '*.tgz'
            tar xzf $argv[1]
        case '*.tar.xz'
            tar xJf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            unrar e $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*'
            echo "Error: '$argv[1]' cannot be extracted - unknown archive format"
            return 1
    end
end

# Find and kill process by name
function killp
    if test (count $argv) -ne 1
        echo "Usage: killp <process_name>"
        return 1
    end

    set pids (pgrep -f $argv[1])
    if test (count $pids) -eq 0
        echo "No process found matching: $argv[1]"
        return 1
    end

    echo "Found processes:"
    ps -p $pids

    read -P "Kill these processes? [y/N] " confirm
    if test "$confirm" = y -o "$confirm" = Y
        kill $pids
        echo "Processes killed"
    else
        echo "Cancelled"
    end
end

# Simple HTTP server
function serve
    set port 8000
    if test (count $argv) -ge 1
        set port $argv[1]
    end

    if command -v python3 >/dev/null
        python3 -m http.server $port
    else if command -v python >/dev/null
        python -m SimpleHTTPServer $port
    else
        echo "Error: Python not found"
        return 1
    end
end

# Generate random password
function genpass
    set length 16
    if test (count $argv) -ge 1
        set length $argv[1]
    end

    if command -v openssl >/dev/null
        openssl rand -base64 $length | head -c $length
        echo
    else
        echo "Error: openssl not found"
        return 1
    end
end

# Git commit and push
function gcp
    if test (count $argv) -eq 0
        echo "Usage: gcp <commit_message>"
        return 1
    end

    git add -A
    git commit -m "$argv"
    git push
end

# Quick project setup
function newproject
    if test (count $argv) -ne 1
        echo "Usage: newproject <project_name>"
        return 1
    end

    set project_name $argv[1]
    mkdir -p $project_name
    cd $project_name

    # Initialize git
    git init
    echo "# $project_name" > README.md
    echo ".DS_Store" > .gitignore
    echo "*.log" >> .gitignore
    echo "node_modules/" >> .gitignore
    echo ".env" >> .gitignore

    git add .
    git commit -m "Initial commit"

    echo "Project '$project_name' created and initialized"
end

# ============================================================================
# GREETING
# ============================================================================

function fish_greeting
    # Display a friendly greeting with system info
    set_color cyan
    echo "🐟 Welcome back, $USER! 🐟"
    set_color normal

    # Show current time and date
    set_color yellow
    echo "📅 $(date '+%A, %B %d, %Y at %I:%M %p')"
    set_color normal

    # Show current directory if not home
    if test $PWD != $HOME
        set_color green
        echo "📂 Current directory: $(basename $PWD)"
        set_color normal
    end

    # Show Git status if in a Git repository
    if git rev-parse --git-dir >/dev/null 2>&1
        set git_branch (git branch --show-current 2>/dev/null)
        if test -n "$git_branch"
            set_color magenta
            echo "🌿 Git branch: $git_branch"
            set_color normal
        end
    end

    echo
end

# ============================================================================
# LOAD ADDITIONAL CONFIGURATIONS
# ============================================================================

# Load local configuration if it exists
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end

# Load work-specific configuration if it exists
if test -f ~/.config/fish/work.fish
    source ~/.config/fish/work.fish
end

# Load private configuration if it exists
if test -f ~/.config/fish/private.fish
    source ~/.config/fish/private.fish
end

# ============================================================================
# STARTUP TASKS
# ============================================================================

# Check for system updates (macOS)
if test (uname) = Darwin
    # Check if it's been more than a week since last update check
    set last_check_file ~/.config/fish/.last_update_check
    set current_time (date +%s)
    set week_in_seconds 604800

    if not test -f $last_check_file
        or test (math $current_time - (cat $last_check_file 2>/dev/null || echo 0)) -gt $week_in_seconds
        echo $current_time > $last_check_file
        set_color yellow
        echo "💡 Consider running 'brew update && brew upgrade' to update your packages"
        set_color normal
    end
end
