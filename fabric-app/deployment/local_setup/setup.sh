#!/usr/bin/env bash
set -euo pipefail 2>/dev/null || set -eu

# shellcheck disable=SC1091  # Suppress warnings about sourcing external files

# Get the repo root directory (3 levels up from this script)
REPO_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"

# Source shared utilities from repo root
source "$REPO_ROOT/common/scripts/utils.sh"

# Change to the fabric-app directory (the dbt project root)
cd "$(dirname "$0")/../../" || { echo "Failed to cd to fabric-app directory"; exit 1; }

echo "Starting dbt project setup..."

# Validate we're in a dbt project directory
if [ ! -f "dbt_project.yml" ]; then
  echo "Error: dbt_project.yml not found. Please run this script from the root of a dbt project."
  exit 1
fi

# Helper function for Linux uv binary installation
install_linux_uv_binary() {
  rm -f "$HOME/.local/bin/uv" "$HOME/.local/bin/uvx" 2>/dev/null || true
  mkdir -p "$HOME/.local/bin"
  echo "Downloading Linux uv binary directly..."
  curl -LsSf https://github.com/astral-sh/uv/releases/download/0.8.15/uv-x86_64-unknown-linux-gnu.tar.gz | tar -xz -C /tmp
  mv /tmp/uv-x86_64-unknown-linux-gnu/uv "$HOME/.local/bin/"
  mv /tmp/uv-x86_64-unknown-linux-gnu/uvx "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/uv" "$HOME/.local/bin/uvx"
  rm -rf /tmp/uv-x86_64-unknown-linux-gnu
  export PATH="$HOME/.local/bin:$PATH"
  hash -r
}

# Detect OS type using shared utility
OS_TYPE=$(detect_os)
PROJECT_NAME=$(basename "$PWD")
echo "Detected OS: $OS_TYPE"

# Check if sudo is available (skip on Windows)
if [[ "$OS_TYPE" != "windows" ]]; then
  if ! command -v sudo &> /dev/null; then
    echo "'sudo' command not found. This script requires sudo privileges."
    echo "Please install sudo or contact your administrator."
    exit 1
  fi
fi

# Check for Python (Windows/Linux)
PYTHON_CMD=$(command -v python3 || command -v python || true)
if [ -z "$PYTHON_CMD" ]; then
  echo "Python 3 is required but was not found. Please install it before proceeding."
  exit 1
fi
echo "Found Python: $($PYTHON_CMD --version)"

# Install uv if missing (Windows/Linux)
if ! command -v uv &> /dev/null; then
  echo "'uv' not found. Installing globally..."
  # Recommended by uv maintainers:
  # https://github.com/astral-sh/uv#installation
  # This uses a secure install script to fetch the latest Rust-native binary.
  # Handle macOS architecture: arm64 (Apple Silicon) or x86_64 (Intel)
  # With fallback to Linux installation if macOS binaries fail (e.g., in Docker)
  if [[ "$OS_TYPE" == "darwin" ]] || [[ "$OS_TYPE" == "mac" ]]; then
    ARCH=$(uname -m)
    MACOS_INSTALL_SUCCESS=false
    if [[ "$ARCH" == "arm64" ]]; then
      echo "Detected Apple Silicon (arm64)."
      # Try installing uv for Apple Silicon
      if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        # Test if the installed binary actually works
        export PATH="$HOME/.local/bin:$PATH"
        if uv --version &> /dev/null; then
          MACOS_INSTALL_SUCCESS=true
        fi
      fi
    elif [[ "$ARCH" == "x86_64" ]]; then
      echo "Detected Intel Mac (x86_64)."
      # Try installing uv for Intel Mac
      if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        # Test if the installed binary actually works
        export PATH="$HOME/.local/bin:$PATH"
        if uv --version &> /dev/null; then
          MACOS_INSTALL_SUCCESS=true
        fi
      fi
    else
      echo "Unsupported macOS architecture: $ARCH"
      exit 1
    fi

    # Fallback to pip if macOS installation failed
    if [[ "$MACOS_INSTALL_SUCCESS" == "false" ]]; then
      echo "macOS uv installation failed, this may happen in containerized environments."
      echo "Continuing without uv - will use pip for package management where needed."
    fi
  else
    # Default installation for Linux/WSL
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi

  # Add ~/.local/bin to PATH for current session
  export PATH="$HOME/.local/bin:$PATH"
  hash -r

  # Verify uv is working, if not handle gracefully for macOS
  if ! uv --version &> /dev/null; then
    if [[ "$OS_TYPE" == "darwin" ]] || [[ "$OS_TYPE" == "mac" ]]; then
      echo "Installed uv binary is not working (likely architecture mismatch in container)."
      echo "Will use pip for Python package management where needed."
    fi
  fi

  if ! command -v uv &> /dev/null; then
    if [[ "$OS_TYPE" == "darwin" ]] || [[ "$OS_TYPE" == "mac" ]]; then
      echo "uv not available on macOS (common in containers). Continuing with pip fallback..."
    else
      echo "Failed to install 'uv'. Please check the install logs or restart your shell."
      exit 1
    fi
  fi
fi

# Install pre-commit globally if missing
if ! command -v pre-commit &> /dev/null; then
  echo "'pre-commit' not found. Installing globally..."
  # Additional fallback check before using uv for pre-commit
  if ! uv --version &> /dev/null; then
    if [[ "$OS_TYPE" == "darwin" ]] || [[ "$OS_TYPE" == "mac" ]]; then
      echo "uv binary not working on macOS, trying pip install..."
      if command -v pip3 &> /dev/null; then
        pip3 install --user pre-commit
      elif command -v pip &> /dev/null; then
        pip install --user pre-commit
      else
        echo "Warning: Neither uv nor pip available. Please install pre-commit manually."
        return 1
      fi
    else
      echo "uv binary not working, applying Linux fallback..."
      install_linux_uv_binary
    fi
  else
    uv tool install pre-commit
  fi
  echo "✓ Pre-commit installed globally"
fi

# Create virtual environment and install dependencies
VENV_PATH=$(get_venv_path "$PROJECT_NAME" "$OS_TYPE")
echo "Using virtual environment: $VENV_PATH"

if [[ "$OS_TYPE" == "wsl" ]]; then
  # For WSL, work entirely from Linux filesystem to avoid permission issues
  TEMP_PROJECT_PATH="/tmp/dbt-fabric-setup-$$"
  ORIGINAL_DIR="$PWD"
  echo "WSL detected: copying project to Linux filesystem to avoid permission issues..."

  rm -rf .venv "$VENV_PATH" "$TEMP_PROJECT_PATH" 2>/dev/null || true
  mkdir -p "$TEMP_PROJECT_PATH"
  cp -r . "$TEMP_PROJECT_PATH/"
  cd "$TEMP_PROJECT_PATH"

  # Create venv and install dependencies in temp location
  echo "Installing dependencies using uv (pyproject.toml)..."
  uv venv --clear
  source .venv/bin/activate
  uv sync
  echo "✓ Dependencies installed successfully in temp location"

  # Copy the entire venv to WSL temp location
  echo "Copying venv to WSL location..."
  cp -r .venv "$VENV_PATH"
  # Fix ownership and permissions of the copied venv
  chown -R "$(whoami):$(id -gn)" "$VENV_PATH" 2>/dev/null || true
  # Fix VIRTUAL_ENV path in activation script
  sed -i "s|VIRTUAL_ENV='.*'|VIRTUAL_ENV='$VENV_PATH'|" "$VENV_PATH/bin/activate"
  # Fix the prompt name to match the project
  sed -i 's|if \[ "x[^"]*" != x \]|if [ "x'"$PROJECT_NAME"'" != x ]|' "$VENV_PATH/bin/activate"
  sed -i 's|VIRTUAL_ENV_PROMPT="[^"]*"|VIRTUAL_ENV_PROMPT="'"$PROJECT_NAME"'"|' "$VENV_PATH/bin/activate"
  # Fix Python shebang paths in all executables
  find "$VENV_PATH/bin" -type f -executable -exec sed -i "1s|^#!.*python.*|#!$VENV_PATH/bin/python3|" {} \;
  cd "$ORIGINAL_DIR"
  rm -rf "$TEMP_PROJECT_PATH"
else
  # Regular installation for non-WSL environments
  echo "Installing dependencies using uv (pyproject.toml)..."
  uv venv --clear
  uv sync
  echo "✓ Dependencies installed successfully"
fi

# Activate virtual environment
ACTIVATE_SCRIPT=$(get_activate_script "$VENV_PATH" "$OS_TYPE")
if [[ -f "$ACTIVATE_SCRIPT" ]]; then
  # shellcheck disable=SC1090  # Dynamic script path
  source "$ACTIVATE_SCRIPT"
  # For WSL, explicitly add venv bin to PATH since activation may not work properly
  if [[ "$OS_TYPE" == "wsl" ]]; then
    export PATH="$VENV_PATH/bin:$PATH"
  fi
else
  echo "Error: Virtual environment activation failed"
  exit 1
fi

# Verify dbt installation
echo "Verifying dbt installation..."
if command -v dbt &> /dev/null; then
  DBT_VERSION=$(dbt --version 2>&1 | head -1)
  echo "✓ dbt installed successfully: $DBT_VERSION"
else
  echo "❌ dbt not found in PATH. Installation may have failed."
  exit 1
fi

# Install pre-commit hooks if .pre-commit-config.yaml exists
if [ -f ".pre-commit-config.yaml" ]; then
  echo "Installing pre-commit hooks..."
  pre-commit install
  echo "✓ Pre-commit hooks installed"
else
  echo "No .pre-commit-config.yaml found, skipping pre-commit hook installation."
fi

# Handle ODBC driver installation depending on OS
if [[ "$OS_TYPE" == "wsl" || "$OS_TYPE" == "linux" ]]; then
  echo "Detected $OS_TYPE environment."

  # Install prerequisite system packages
  echo "Installing prerequisite system packages..."
  if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu systems
    sudo apt-get update
    sudo apt-get install -y curl gnupg lsb-release unixodbc unixodbc-dev
  elif command -v yum &> /dev/null; then
    # RHEL/CentOS systems
    sudo yum install -y curl gnupg2 redhat-lsb-core unixODBC unixODBC-devel
  elif command -v dnf &> /dev/null; then
    # Fedora systems
    sudo dnf install -y curl gnupg2 redhat-lsb-core unixODBC unixODBC-devel
  else
    echo "Warning: Unknown package manager. Please install curl, gnupg, lsb-release, and unixODBC manually."
  fi

  if ! ldconfig -p | grep -q libodbc.so.2; then
    echo "Warning: unixODBC may not be properly installed."
  else
    echo "unixODBC is available."
  fi

  if command -v odbcinst &> /dev/null && ! odbcinst -q -d | grep -q "ODBC Driver 18 for SQL Server"; then
    echo "Installing Microsoft ODBC Driver 18 for SQL Server..."
    if command -v gpg &> /dev/null && command -v lsb_release &> /dev/null; then
      curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
      sudo mkdir -p /etc/apt/keyrings
      sudo mv microsoft.gpg /etc/apt/keyrings/
      UBUNTU_VERSION=$(lsb_release -rs)
      UBUNTU_CODENAME=$(lsb_release -cs)
      echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/${UBUNTU_VERSION}/prod ${UBUNTU_CODENAME} main" | sudo tee /etc/apt/sources.list.d/mssql-release.list
      sudo apt-get update
      sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
    else
      echo "Warning: gpg or lsb_release not available. Skipping Microsoft ODBC Driver installation."
      echo "Please install manually from: https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server"
    fi
  else
    if command -v odbcinst &> /dev/null; then
      echo "Microsoft ODBC Driver 18 is already installed."
    else
      echo "Warning: odbcinst not available. Cannot verify ODBC driver installation."
    fi
  fi

elif [[ "$OS_TYPE" == "mac" ]]; then
  echo "Detected macOS environment."

  # Check for Homebrew and install ODBC drivers
  if command -v brew &> /dev/null; then
    echo "Installing ODBC drivers via Homebrew..."
    if ! brew list unixodbc &> /dev/null; then
      brew install unixodbc
    else
      echo "unixODBC already installed via Homebrew."
    fi

    if ! brew list microsoft-odbc-driver &> /dev/null; then
      echo "Installing Microsoft ODBC Driver 18 for SQL Server..."
      brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
      brew install microsoft-odbc-driver || echo "Note: Microsoft ODBC Driver installation may have failed. Please install manually if needed."
    else
      echo "Microsoft ODBC Driver is already installed via Homebrew."
    fi
  else
    echo "Homebrew not found. Please install ODBC drivers manually:"
    echo "1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "2. Install ODBC drivers: brew install unixodbc && brew tap microsoft/mssql-release && brew install microsoft-odbc-driver"
  fi

elif [[ "$OS_TYPE" == "windows" ]]; then
  echo "Detected Windows environment."
  # Check for ODBC Driver installation (using PowerShell command)
  if ! powershell.exe -Command "Get-OdbcDriver | Where-Object { \$_.Name -like '*ODBC Driver 18 for SQL Server*' }" | grep -q "ODBC Driver 18"; then
    echo "ODBC Driver 18 for SQL Server is not installed."
    echo "Please install it manually from:"
    echo "https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server"
    echo "or install via winget or choco if available:"
    echo "  winget install --id Microsoft.SQLServer.OdbcDriver --source winget"
    echo "  choco install microsoft-odbc-driver-for-sql-server"
  else
    echo "Microsoft ODBC Driver 18 is already installed."
  fi
else
  echo "Unsupported OS type: $OS_TYPE. Please install ODBC drivers manually if needed."
fi

echo ""
echo "🎉 Setup complete! Running: dbt --version"
dbt --version
echo ""

echo ""
echo "🎉 Installing dbt packages"
dbt deps
echo "✓ dbt packages installed"

echo "To activate your environment later, run:"
echo "    source venv $PROJECT_NAME"
echo "To load environment variables from .env:"
echo "    export \$(grep -v '^#' .env | grep -E '^(FABRIC_CLIENT_ID|FABRIC_CLIENT_SECRET|FABRIC_TENANT_ID|FABRIC_SERVER|FABRIC_SCHEMA|FABRIC_DATABASE)=' | xargs)"
