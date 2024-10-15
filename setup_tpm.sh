#!/bin/bash

PLUGIN_FOLDER="$HOME/.tmux/plugins/tpm"

if [ ! -d "$PLUGIN_FOLDER" ]; then
    git clone https://github.com/tmux-plugins/tpm "$PLUGIN_FOLDER"
else
    if [ -z "$(ls -A $PLUGIN_FOLDER)" ]; then
        echo "$PLUGIN_FOLDER is empty, cloning..."
        git clone https://github.com/tmux-plugins/tpm "$PLUGIN_FOLDER"
    else
        echo "$PLUGIN_FOLDER is not empty."
    fi
fi
