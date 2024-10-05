#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <Working Directory> <Session Name> <Conda Environment> <Start CMD>"
    exit 1
fi

# Configurations from command line arguments
WORK_DIR="$1"
SESSION_NAME="$2"
CONDA_ENV="$3"
START_CMD="$4"

# CD to working directory
cd "$WORK_DIR" || { echo "Failed to change directory to $WORK_DIR"; exit 1; }

# Create a new tmux session 
tmux new-session -s "$SESSION_NAME" -d

# Activate the Poetry virtual environment in the terminal
tmux send-keys -t "$SESSION_NAME" "source deactivate && conda activate $3 && $START_CMD" Enter

# Attach to tmux session
tmux select-window -t "$SESSION_NAME"
tmux attach -t "$SESSION_NAME"
