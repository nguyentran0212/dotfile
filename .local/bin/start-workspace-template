#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Working Directory> <Session Name> <Conda Environment>"
    exit 1
fi

# Configurations from command line arguments
WORK_DIR="$1"
SESSION_NAME="$2"
CONDA_ENV="$3"

# Check if the tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists. Attaching..."
    tmux attach -t "$SESSION_NAME"
    exit 0
fi

# CD to working directory
cd "$WORK_DIR" || { echo "Failed to change directory to $WORK_DIR"; exit 1; }

# Create a new tmux session 
tmux new-session -s "$SESSION_NAME" -d

# Create a new window and name it editor
tmux rename-window -t "$SESSION_NAME" 'editor'

# Start nvim inside the editor window with activated virtual environment
tmux send-keys -t "$SESSION_NAME:editor" "source deactivate && conda activate $3 && nvim" Enter

# Split the window horizontally and rename the panes
tmux split-window -v -t $SESSION_NAME
tmux select-layout even-vertical -t $SESSION_NAME

# Create a new window for the command line terminal
tmux new-window -t "$SESSION_NAME" -n 'terminal'

# Activate the Poetry virtual environment in the terminal
tmux send-keys -t "$SESSION_NAME:terminal" "source deactivate && conda activate $3" Enter

# Attach to tmux session
tmux select-window -t "$SESSION_NAME:editor"
tmux attach -t "$SESSION_NAME"
