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

# Create a new tmux session 
tmux new-session -s $SESSION_NAME -d

# Rename the top pane to 'editor'
tmux rename-window -t $SESSION_NAME 'editor'

# Start nvim inside the top pane
tmux send-keys -t $SESSION_NAME 'nvim' Enter

# Split the window horizontally and rename the panes
tmux split-window -v -t $SESSION_NAME
tmux select-layout even-vertical -t $SESSION_NAME

# Attach to tmux session
tmux attach -t $SESSION_NAME
