#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Session Name> <User Name> <Hostname>"
    exit 1
fi

# Configurations from command line arguments
SESSION_NAME="$1"
USER_NAME="$2"
HOST_NAME="$3"

# Check if the tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists. Attaching..."
    tmux attach -t "$SESSION_NAME"
    exit 0
fi

# Create a new tmux session 
tmux new-session -s "$SESSION_NAME" -d

# Create a new window and name it editor
tmux rename-window -t "$SESSION_NAME" 'ssh'

# Start nvim inside the editor window with activated virtual environment
tmux send-keys -t "$SESSION_NAME:ssh" "ssh $USER_NAME@$HOST_NAME" Enter

# Attach to tmux session
tmux select-window -t "$SESSION_NAME:ssh"
tmux attach -t "$SESSION_NAME"
