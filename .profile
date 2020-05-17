# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

# flutter path
if [ -d "$HOME/Android/flutter/bin" ] ; then
	PATH="$PATH:$HOME/Android/flutter/bin"
fi

# default editor
export VISUAL=nvim
export EDITOR="$VISUAL"
