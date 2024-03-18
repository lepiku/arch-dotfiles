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

# android path
if [ -d "$HOME/Android/Sdk" ] ; then
    PATH="$PATH:$HOME/Android/Sdk/platform-tools"
    PATH="$PATH:$HOME/Android/Sdk/emulator"
fi

# for pyenv
if [ -f /usr/bin/pyenv ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
fi

if [ -f ~/.keys ]; then
    . ~/.keys
fi

# default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

export GOPATH="$HOME/.go"

# flutter
export CHROME_EXECUTABLE="/usr/bin/chromium"
# ionic capacitor
export CAPACITOR_ANDROID_STUDIO_PATH="/usr/bin/android-studio"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
