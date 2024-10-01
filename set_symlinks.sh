#!/bin/bash

CURRENT_DIR=$(pwd)

# Symlink the nvim config from this directory to the configuration folder
ln -sF $CURRENT_DIR/nvim $HOME/.config
