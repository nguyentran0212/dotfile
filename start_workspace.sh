#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Workspace Name>"
    exit 1
fi

# Load the environment variables from configs.json file
if [ ! -f configs.json ]; then
    echo "configs.json file not found!"
    exit 1
fi

# Load arguments for the workspace to open
WORKSPACE_NAME="$1"
SESSION_NAME="$1"
WORKSPACE_TYPE=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].workspace_type' configs.json 2>/dev/null || echo "")

# Check workspace type loaded properly
if [ "$WORKSPACE_TYPE" = "null" ]; then
    echo "Error: WORKSPACE_TYPE of $WORKSPACE_NAME is not found in the configs.json! Hint: ensure the workspace name is correct and configs.json has been set up properly."
    exit 1
fi

# Load working directory from configs and parse
WORK_DIR=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].workspace_dir' configs.json 2>/dev/null || echo "")

# Check if workspace directory and workspace type loaded properly
if [ "$WORK_DIR" != "null" ]; then
    echo "Found $WORK_DIR for workspace $WORKSPACE_NAME in the configs.json..."
  # Resolve $HOME/path/to/workspace 
  WORK_DIR=$(eval echo "$WORK_DIR")  # Security risk. However, if attacker can run this script, the host has been pwned anyway.
  if [ $? -ne 0 ]; then
      echo "Error resolving the path: $WORK_DIR"
      exit 1
  fi
fi

# Call suitable scripts to start the workspace
case "$WORKSPACE_TYPE" in
  "poetry") ./scripts/start_workspace_poetry.sh $WORK_DIR $SESSION_NAME
  ;;
  "poetry_run") START_CMD=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].start_cmd' configs.json) && ./scripts/start_workspace_poetry_run.sh $WORK_DIR $SESSION_NAME "$START_CMD"
  ;;
  "conda") CONDA_ENV=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].conda_env' configs.json) && ./scripts/start_workspace_python_conda.sh $WORK_DIR $SESSION_NAME $CONDA_ENV
  ;;
  "conda_run") CONDA_ENV=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].conda_env' configs.json) && START_CMD=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].start_cmd' configs.json) && ./scripts/start_workspace_conda_run.sh $WORK_DIR $SESSION_NAME "$CONDA_ENV" "$START_CMD"
  ;;
  "ssh") HOST_NAME=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].host_name' configs.json) && USER_NAME=$(jq -r --arg workspace_name "$WORKSPACE_NAME" '.[$workspace_name].user_name' configs.json) && ./scripts/start_workspace_ssh.sh $SESSION_NAME $USER_NAME $HOST_NAME
  ;;
  "latex") ./scripts/start_workspace_latex.sh $WORK_DIR $SESSION_NAME
  ;;
  "dashboard") ./scripts/start_dashboard.sh
  ;;
  *) ./scripts/start_workspace_nvim.sh $WORK_DIR $SESSION_NAME
  ;;
esac

