# dbt-starter-fabric

Welcome to the dbt starter repository for Microsoft Fabric! This project provides a solid foundation for building, testing, and deploying dbt models on the Fabric platform.

## What's Included

This repository comes pre-configured with:

*   **Multi-Platform Support**: Includes dbt configurations for Fabric, BigQuery, Snowflake, and Databricks platforms.
*   **A Modular Data Model Structure**: Following dbt best practices, we have organized the `models` directory into `staging`, `intermediate`, and `marts` layers.
*   **Example Models**: Sample models are included to help you quickly validate your connection and run your first dbt job.
*   **Automated Setup Scripts**: Cross-platform setup scripts for quick environment configuration.
*   **Docker Testing Environment**: Containerized testing for Linux and WSL compatibility.
*   **Pre-configured Python Environment**: We use `uv` for fast and reproducible dependency management.

## Prerequisites

Before you begin, ensure you have the following installed:

*   **Python**: Version 3.12
*   **uv**: For Python environment and package management (automatically installed by setup script)
*   **dbt**: The required adapter (e.g `dbt-fabric` or `dbt-bigquery`) adapter is included in the `pyproject.toml` file.
*   **pre-commit**: For code quality and formatting checks

### Installing pre-commit

Choose one of the following methods:

**Option 1: Using pip**
```bash
pip install pre-commit
```

**Option 2: Using pipx (recommended for global tools)**
```bash
pipx install pre-commit
```

**Option 3: Using conda**
```bash
conda install -c conda-forge pre-commit
```

After installation, initialize pre-commit in the repository:
```bash
pre-commit install
```

## How to Get Started (fabric-app)

1.  **Clone** the repository.

2.  **Setup** (first time only):
    ```bash
    cd fabric-app # or bigquery-app, or any other dbt project
    sudo bash deployment/local_setup/setup.sh
    ```

3.  **Activate environment**:
    ```bash
    source venv fabric-app # or bigquery-app, or any other dbt project
    ```

4.  **Test your setup**:
    ```bash
    dbt debug
    dbt build
    ```

### Alternative Manual Setup

If you prefer manual setup or encounter issues with the automated script, follow our detailed **[Quickstart Guide](guidelines/quickstart.md)**.

## Documentation Hub

🔗 For contribution guides, modeling standards, platform comparisons, and more, please see our [**central documentation hub**](https://dev.azure.com/ValconDevOps/DBT/_wiki/wikis/DBT.wiki/1847/DBT-Community).

## TODO

* **macOS Testing**: Implement macOS compatibility testing using Azure DevOps pipelines

## Maintainers

This repository is maintained by:

*   The Data Platform Team

For questions or support, please reach out to us at `data-platform-team@valcon.com` or in the `#dbt-community` Slack channel.
