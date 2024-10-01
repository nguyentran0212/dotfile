#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <Workspace Name> <Workspace Type>"
    exit 1
fi

# Load the environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Get the workspace name and session name from the command line arguments
WORKSPACE_NAME="$1"
SESSION_NAME="$1"
WORKSPACE_TYPE="$2"

# Check if the workspace variable is set
WORK_DIR="${!WORKSPACE_NAME}"  # This will generally be $HOME/path/to/workspace
if [ -z "$WORK_DIR" ]; then
    echo "Workspace '$WORKSPACE_NAME' not found in .env file."
    exit 1
else
    echo "Resolved WORK_DIR: $WORK_DIR"
fi

# Resolve $HOME/path/to/workspace 
WORK_DIR=$(eval echo "$WORK_DIR")  # Security risk. However, if attacker can run this script, the host has been pwned anyway.
if [ $? -ne 0 ]; then
    echo "Error resolving the path: $WORK_DIR"
    exit 1
fi

case "$WORKSPACE_TYPE" in
  "python") ./scripts/start_workspace_python.sh $WORK_DIR $SESSION_NAME
  ;;
  "conda") CONDA_ENV="$3" && ./scripts/start_workspace_python_conda.sh $WORK_DIR $SESSION_NAME $CONDA_ENV
  ;;
  "latex") ./scripts/start_workspace_latex.sh $WORK_DIR $SESSION_NAME
  ;;
  *) ./scripts/start_workspace_nvim.sh $WORK_DIR $SESSION_NAME
  ;;
esac

