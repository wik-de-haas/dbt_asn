# Docker Testing Setup

This setup allows you to test your dbt setup script across Ubuntu/WSL, Linux, and macOS environments using Docker.

## Files Created

- `docker/Dockerfile.ubuntu` - Ubuntu 22.04 environment (WSL simulation)
- `docker/Dockerfile.linux` - Pure Linux environment with Python 3.12
- `docker/Dockerfile.macos` - macOS simulation environment
- `docker-compose.yml` - Multi-environment orchestration
- `test-environments.sh` - Automated test runner

## Usage

### Run All Tests Automatically
```bash
bash test-environments.sh
```

### Test Individual Environments

**Ubuntu/WSL:**
```bash
docker-compose up -d ubuntu-wsl
docker-compose exec ubuntu-wsl bash fabric-app/deployment/local_setup/setup.sh
docker-compose stop ubuntu-wsl
```

**Linux:**
```bash
docker-compose up -d linux
docker-compose exec linux bash fabric-app/deployment/local_setup/setup.sh
docker-compose stop linux
```

**macOS Simulation:**
```bash
docker-compose up -d macos
docker-compose exec macos bash fabric-app/deployment/local_setup/setup.sh
docker-compose stop macos
```

### Interactive Testing
```bash
# Start a specific environment
docker-compose run --rm ubuntu-wsl bash

# Inside the container, run your setup
bash fabric-app/deployment/local_setup/setup.sh

# Test other commands as needed
source fabric-app/.venv/bin/activate
dbt --version
```

## Clean Up
```bash
docker-compose down
docker system prune -f
```

## Environment Differences

- **Ubuntu/WSL**: Simulates WSL2 environment with Ubuntu 22.04
- **Linux**: Pure Python 3.12 slim image
- **macOS**: Simulates macOS with Darwin environment variables and file structure
