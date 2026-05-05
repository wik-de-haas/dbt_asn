#!/usr/bin/env bash

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "windows"
  elif [[ -f /.dockerenv ]]; then
    # Running inside a Docker container for testing
    # ubuntu-wsl container should simulate WSL behavior, linux container should be linux
    if [[ "$HOSTNAME" == *"ubuntu"* ]] || [[ "$(docker inspect --format='{{.Name}}' "$(hostname)" 2>/dev/null)" == *"ubuntu"* ]]; then
      echo "wsl"  # ubuntu-wsl container simulates WSL
    else
      echo "linux"  # linux container
    fi
  elif grep -q -i microsoft /proc/version 2>/dev/null; then
    echo "wsl"  # Real WSL environment
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"  # Real Linux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "mac"  # Real macOS
  else
    echo "linux"  # Default to linux
  fi
}

# Get venv path - simplified logic
get_venv_path() {
  local os_type="${2:-$(detect_os)}"
  if [[ "$os_type" == "wsl" ]]; then
    echo "/tmp/venv-${1:-project}"
  else
    echo ".venv"
  fi
}

# Get activation script path
get_activate_script() {
  local venv_path="${1:-.venv}"
  local os_type="${2:-$(detect_os)}"

  if [[ "$os_type" == "windows" ]]; then
    echo "$venv_path/Scripts/activate"
  else
    echo "$venv_path/bin/activate"
  fi
}

# Activate virtual environment function
activate_venv() {
  local project_name="${1:-project}"
  local os_type="${2:-$(detect_os)}"
  local venv_path=$(get_venv_path "$project_name" "$os_type")
  local activate_script=$(get_activate_script "$venv_path" "$os_type")

  if [[ -f "$activate_script" ]]; then
    source "$activate_script"
    # For WSL, also explicitly add venv bin to PATH since activation may not work properly
    if [[ "$os_type" == "wsl" ]]; then
      export PATH="$venv_path/bin:$PATH"
    fi
    echo "✓ Activated virtual environment: $venv_path"
    return 0
  else
    # Fallback: try local .venv if WSL path doesn't exist
    if [[ "$os_type" == "wsl" && -f ".venv/bin/activate" ]]; then
      source ".venv/bin/activate"
      export PATH=".venv/bin:$PATH"
      echo "✓ Activated local virtual environment: .venv"
      return 0
    fi
    echo "❌ Virtual environment not found at: $activate_script"
    return 1
  fi
}

# Wrapper function to be called as 'venv <project-name>'
venv() {
  local project_name="${1:-project}"
  activate_venv "$project_name"
}
