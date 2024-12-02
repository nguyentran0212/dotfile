#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Working Directory> <Session Name> <Start CMD>"
    exit 1
fi

# Configurations from command line arguments
WORK_DIR="$1"
SESSION_NAME="$2"
START_CMD="$3"

# Check if the tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists. Attaching..."
    tmux attach -t "$SESSION_NAME"
    exit 0
fi

# CD to working directory
cd "$WORK_DIR" || { echo "Failed to change directory to $WORK_DIR"; exit 1; }

# Get the path to the Poetry virtual environment
VENV_PATH=$(poetry env info --path)

# Create a new tmux session 
tmux new-session -s "$SESSION_NAME" -d
tmux send-keys -t "$SESSION_NAME" "source $VENV_PATH/bin/activate && $START_CMD" Enter

# Attach to tmux session
tmux select-window -t "$SESSION_NAME"
tmux attach -t "$SESSION_NAME"
