#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

if [ -f ~/.zsh_aliases ]; then
	. ~/.zsh_aliases
fi
if [ -f ~/.keys ]; then
	. ~/.keys
fi

# enable/disable conda with 'conda-toggle'
if [ -f ~/.condainit ]; then
	. ~/.condainit
fi

# fzf plugin settings
export FZF_DEFAULT_COMMAND='fd --type f -I --hidden --follow --max-depth 5'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d -I --hidden --follow --max-depth 5'
export FZF_VIM_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40%'

# not disturb ctrl-s and ctrl-q
stty -ixon
