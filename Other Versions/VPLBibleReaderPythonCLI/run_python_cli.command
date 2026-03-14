#!/bin/bash

# Get the directory where this script is located
PARENT_DIR=$(cd "$(dirname "$0")" && pwd)

# Navigate to that directory
cd "$PARENT_DIR" || exit

# Define the script to run
SCRIPT="main.py"

# Check if the script exists first
if [[ ! -f "$SCRIPT" ]]; then
    echo "Error: $SCRIPT not found."
    exit 1
fi

# Try 'python', then 'python3', then 'python2'
if command -v python >/dev/null 2>&1; then
    echo "Running with python..."
    python "$SCRIPT"
elif command -v python3 >/dev/null 2>&1; then
    echo "Running with python3..."
    python3 "$SCRIPT"
elif command -v python2 >/dev/null 2>&1; then
    echo "Running with python2..."
    python2 "$SCRIPT"
else
    echo "Error: No Python interpreter found in your PATH."
    exit 1
fi