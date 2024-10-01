#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <Working Directory> <Session Name>"
    exit 1
fi

# Configurations from command line arguments
WORK_DIR="$1"
SESSION_NAME="$2"

# CD to working directory
cd "$WORK_DIR" || { echo "Failed to change directory to $WORK_DIR"; exit 1; }

# Get the path to the Poetry virtual environment
VENV_PATH=$(poetry env info --path)

# Create a new tmux session 
tmux new-session -s "$SESSION_NAME" -d

# Create a new window and name it editor
tmux rename-window -t "$SESSION_NAME" 'editor'

# Start nvim inside the editor window with activated virtual environment
tmux send-keys -t "$SESSION_NAME:editor" "source $VENV_PATH/bin/activate && nvim" Enter

# Create a new window for the command line terminal
tmux new-window -t "$SESSION_NAME" -n 'terminal'

# Activate the Poetry virtual environment in the terminal
tmux send-keys -t "$SESSION_NAME:terminal" "source $VENV_PATH/bin/activate" Enter

# Attach to tmux session
tmux select-window -t "$SESSION_NAME:editor"
tmux attach -t "$SESSION_NAME"
