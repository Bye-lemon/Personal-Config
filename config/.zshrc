# Set $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set themes
ZSH_THEME="spaceship"

# Enable plugins
plugins=(
    git
    zsh-syntax-highlighting
    extract
    z
    safe-paste
    zsh-completions
    zsh-autosuggestions
    asdf
    colored-man-pages
    pdm
)

source $ZSH/oh-my-zsh.sh

# Set environment
export LANG=en_US.UTF-8
export EDITOR="nvim"
export TERM="xterm-256color"
export BAT_THEME="Dracula"

# Set alias
if [[ -e ~/.alias ]]; then
    source ~/.alias
fi