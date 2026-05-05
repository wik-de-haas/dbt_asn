#!/bin/bash
set -e

# Set PATH to include ~/.local/bin for all users
export PATH="$HOME/.local/bin:$PATH"

# Fix ownership of mounted volume
if [ -d "/home/testuser/dbt" ]; then
    sudo chown -R testuser:testuser /home/testuser/dbt
fi

# Fix ownership for macOS path
if [ -d "/Users/macuser/dbt" ]; then
    sudo chown -R macuser:macuser /Users/macuser/dbt
fi

# Execute the original command
exec "$@"
