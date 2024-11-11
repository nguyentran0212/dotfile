#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 0 ]; then
    echo "Usage: $0"
    exit 1
fi

SESSION_NAME="dashboard"

# Check if the tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists. Attaching..."
    tmux attach -t "$SESSION_NAME"
    exit 0
fi

# Create a new tmux session 
tmux new-session -s "$SESSION_NAME" -d

tmux send-keys -t "$SESSION_NAME" "dooit" Enter

tmux split-window -v -t $SESSION_NAME
tmux send-keys -t "$SESSION_NAME" "neofetch" Enter

tmux split-window -h -t $SESSION_NAME
tmux clock-mode

# Attach to tmux session
tmux select-window -t "$SESSION_NAME"
tmux attach -t "$SESSION_NAME"
