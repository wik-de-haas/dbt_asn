#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test environments - Docker testing for WSL and Linux only (setup script supports real macOS)
ENVIRONMENTS=("ubuntu-wsl" "linux")

echo "🧪 Testing setup script across different environments..."
echo "======================================================="

# Function to get container name
get_container_name() {
    local env=$1
    case "$env" in
        "ubuntu-wsl") echo "dbt-test-ubuntu";;
        *) echo "dbt-test-${env}";;
    esac
}

# Function to ensure container is running and managed by docker-compose
ensure_container_running() {
    local env=$1
    local container_name=$(get_container_name $env)

    # Check if docker-compose can communicate with the container
    if docker-compose exec -T $env echo "test" >/dev/null 2>&1; then
        echo "Container ${container_name} is running and managed by docker-compose."
        return 0
    fi

    # Check if container exists but not managed by docker-compose
    if docker ps -a --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "Container ${container_name} exists but not managed by docker-compose. Restarting..."
        # Stop and remove the container, then start with docker-compose
        docker rm -f ${container_name} >/dev/null 2>&1
        docker-compose up -d $env

        # Verify it's now working
        if docker-compose exec -T $env echo "test" >/dev/null 2>&1; then
            echo "Container ${container_name} successfully restarted with docker-compose."
            return 0
        else
            echo "Failed to restart container ${container_name} with docker-compose."
            return 1
        fi
    else
        echo "Container ${container_name} doesn't exist. Creating with docker-compose..."
        docker-compose up -d $env

        # Verify it's working
        if docker-compose exec -T $env echo "test" >/dev/null 2>&1; then
            echo "Container ${container_name} successfully created."
            return 0
        else
            echo "Failed to create container ${container_name}."
            return 1
        fi
    fi
}

# Build all images
echo -e "${YELLOW}Building Docker images...${NC}"
docker-compose build

# Function to test environment
test_environment() {
    local env=$1
    echo -e "\n${YELLOW}Testing environment: $env${NC}"
    echo "----------------------------------------"

    # Try to use existing container first
    if ! ensure_container_running $env; then
        echo "Creating new container..."
        docker-compose up -d $env
        # Wait for container to be ready
        echo "Waiting for container to be ready..."
        sleep 30
    fi

    # Check if container is running
    if ! docker-compose ps $env | grep -q "Up"; then
        echo -e "${RED}❌ Container $env failed to start${NC}"
        docker-compose logs $env
        echo "$env: FAILED" >> test_results.txt
        return 1
    fi

    # Test basic connectivity
    echo "Testing container connectivity..."
    if ! docker-compose exec -T $env echo "Container is responsive"; then
        echo -e "${RED}❌ Container $env not responding${NC}"
        docker-compose logs $env
        echo "$env: FAILED" >> test_results.txt
        return 1
    fi

    # Run setup script test
    local success_msg="${GREEN}✅ $env: SUCCESS${NC}"
    local fail_msg="${RED}❌ $env: FAILED${NC}"

    if docker-compose exec -T $env bash -c "
        export PATH=\"\$HOME/.local/bin:\$PATH\" &&
        rm -rf /tmp/dbt-test &&
        mkdir -p /tmp/dbt-test &&
        cp -r . /tmp/dbt-test/ &&
        cd /tmp/dbt-test/fabric-app &&
        bash deployment/local_setup/setup.sh"; then
        echo -e "$success_msg"
        echo "$env: PASSED" >> test_results.txt
    else
        echo -e "$fail_msg"
        echo "$env: FAILED" >> test_results.txt
    fi

    # Stop container (but don't remove it for reuse)
    local container_name=$(get_container_name $env)
    echo "Stopping container ${container_name}..."
    docker stop ${container_name} 2>/dev/null || true
}

# Clean up previous results
rm -f test_results.txt

# Test each environment
for env in "${ENVIRONMENTS[@]}"; do
    test_environment $env
done

echo -e "\n${YELLOW}Test Results Summary:${NC}"
echo "====================="
cat test_results.txt

# Check if all tests passed
if grep -q "FAILED" test_results.txt; then
    echo -e "\n${RED}Some tests failed. Check the output above.${NC}"
    exit 1
else
    echo -e "\n${GREEN}All tests passed! 🎉${NC}"
fi
rm test_results.txt


# Clean up
echo -e "\n${YELLOW}Cleaning up Docker resources...${NC}"
docker-compose down --remove-orphans
docker system prune -f
echo -e "${GREEN}Docker cleanup completed.${NC}"
