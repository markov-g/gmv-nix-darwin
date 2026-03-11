#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: $0 [-s SESSION_NAME] -c COMMAND"
    echo "Send a command to all windows in a tmux session."
    echo
    echo "Options:"
    echo "  -s SESSION_NAME    Specify the name of the tmux session. Default: \${USER}-tmux"
    echo "  -c COMMAND         Specify the command to send to all windows."
    echo "  -h, --help         Display this help message."
}

# Default session name
SESSION_NAME="${USER}-tmux"

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--session)
            SESSION_NAME="$2"
            shift
            ;;
        -c|--command)
            COMMAND="$2"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# Check if command is provided
if [[ -z $COMMAND ]]; then
    echo "Error: Command must be specified."
    usage
    exit 1
fi

# Iterate over each window in the session
tmux list-windows -t "$SESSION_NAME" | awk -F: '{print $1}' | while read -r window_id; do
    # Send the command to each window
    tmux send-keys -t "$SESSION_NAME:$window_id" "$COMMAND" Enter
done

