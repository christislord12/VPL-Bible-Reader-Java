#!/bin/bash

# Get the directory where this script is located
PARENT_DIR=$(cd "$(dirname "$0")" && pwd)

# Navigate to that directory
cd "$PARENT_DIR" || exit

# Run the app
./BibleReaderGUI
