#!/usr/bin/env bash

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi


# Aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# My wrappers for common functions
if [ -f ~/.bash_wrappers ]; then
    . ~/.bash_wrappers
fi

# Rust toolchain
if [ -f $HOME/.cargo/env ]; then
    . "$HOME/.cargo/env"
fi


export ANDROID_HOME=$HOME/Android/Sdk

export PATH
export PATH="$PATH:/opt/android-studio/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$(go env GOPATH)/bin"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export EDITOR="/usr/bin/nvim"

eval "$(zoxide init bash)"

export EMBSYS_HOME="$HOME/Documents/UMary/2026-27/fall-26/embedded-systems"
export QSYS_ROOTDIR="$HOME/altera_lite/25.1std/quartus/sopc_builder/bin"

export MANPAGER="bat -plman"

term_header