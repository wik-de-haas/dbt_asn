# Databricks DBT Project

This dbt project targets Databricks and is designed to work in three ways:
- Local development with personal access token (fastest getting started)
- Local Docker with service principal (container parity)
- Azure DevOps CI using a Secure File (service principal; no Docker needed)

The same [profiles.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app/profiles.yml:0:0-0:0) is used in all cases via environment-variable templating.

## Prerequisites

- Python 3.12
- Bash shell (Git Bash/WSL on Windows, macOS/Linux default)
- Databricks workspace and cluster the account can access
- Databricks personal access token (for local development only)

## Profiles and Authentication

[databricks-app/profiles.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app/profiles.yml:0:0-0:0) is templated:
- `method: "{{ env_var('DBT_METHOD', 'token') }}"`
- `host: "{{ env_var('DATABRICKS_HOST', '') }}"`
- `token: "{{ env_var('DATABRICKS_TOKEN', '') }}"`
- `catalog: "{{ env_var('DATABRICKS_CATALOG', 'unity_catalog') }}"`
- `schema: "{{ env_var('DATABRICKS_SCHEMA', 'test_databricks_dbt') }}"`
- `http_path: "{{ env_var('DATABRICKS_HTTP_PATH', '') }}"`

Modes:
- Local host (Token): do not set `DBT_METHOD` (defaults to `token`), set `DATABRICKS_HOST`, `DATABRICKS_TOKEN`, and `DATABRICKS_HTTP_PATH`.
- Docker/CI (Service Principal): set `DBT_METHOD=service-principal` and provide `DATABRICKS_CLIENT_ID`, `DATABRICKS_CLIENT_SECRET`, and `DATABRICKS_TOKEN`. Optionally set `DATABRICKS_*` if you want to override the defaults.

## Quick Start A: Local development (Token on host)

1) Set environment variables:
- `export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"`
- `export DATABRICKS_TOKEN="your-personal-access-token"`
- `export DATABRICKS_HTTP_PATH="/sql/protocolv1/o/your-cluster-id"`

2) Install and set up the project:
- `cd databricks-app`
- `bash deployment/local_setup/setup.sh`

3) Activate the virtual environment:
- On WSL: `source /tmp/venv-databricks-app/bin/activate`
- On Linux/macOS (non-WSL): `source .venv/bin/activate`
- On Windows PowerShell: `.venv\Scripts\activate`

4) Run dbt:
- `dbt debug`
- `dbt build`

Notes:
- On WSL, the venv location is `/tmp/venv-databricks-app` by design.
- If you copied [.pre-commit-config.yaml](cci:7://file:///c:/dev/DCIWorkspace/DBT/fabric-app/.pre-commit-config.yaml:0:0-0-0) into [databricks-app/](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app:0:0-0-0), install hooks:
  - `pre-commit install`
  - `pre-commit run -a` (optional)

## Quick Start B: Local Docker (Service Principal)

This is optional and mirrors how CI injects credentials at runtime.

1) Create a service principal in Databricks and download its credentials locally (do NOT commit them). Save as:
- `secrets/databricks-sp.json` (this folder is gitignored)

2) Update or verify [docker-compose.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/docker-compose.yml:0:0-0-0) includes:
- A mount for the JSON:
  - `./secrets/databricks-sp.json:/secrets/databricks-sp.json:ro`
- Minimal environment for Databricks auth:
  - `DBT_METHOD=service-principal`
  - `DATABRICKS_CLIENT_ID=/secrets/databricks-sp.json`
  - `DATABRICKS_CLIENT_SECRET=/secrets/databricks-sp.json`
- Optionally also set `DATABRICKS_HOST`, `DATABRICKS_CATALOG`, `DATABRICKS_SCHEMA` to override the defaults from profiles.

3) Build and run a container shell:
- `docker compose build`
- `docker compose run --rm ubuntu-wsl bash`

4) Inside the container:
- `cd databricks-app`
- `bash deployment/local_setup/setup.sh`
- `source .venv/bin/activate`
- `dbt debug`
- `dbt build`

## Quick Start C: Azure DevOps CI (Service Principal Secure File)

A minimal pipeline is provided at:
- [databricks-app/ci/azure-pipelines.yaml](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app/ci/azure-pipelines.yaml:0:0-0-0)

It:
- Uses `ubuntu-latest` host
- Downloads a Secure File (your service principal JSON)
- Installs `uv` and syncs Python dependencies
- Runs `uv run dbt debug/deps/build` with environment variables:
  - `DBT_METHOD=service-principal`
  - `DATABRICKS_HOST`, `DATABRICKS_CATALOG`, `DATABRICKS_SCHEMA`
  - `DATABRICKS_CLIENT_ID=$(downloadSP.secureFilePath)`
  - `DATABRICKS_CLIENT_SECRET=$(downloadSP.secureFilePath)`

Setup steps:
1) In Azure DevOps, upload the JSON to Library > Secure files (e.g., `databricks-sp.json`).
2) Ensure the pipeline task `DownloadSecureFile@1` references that filename.
3) Confirm these env lines exist in the job:
   - `DATABRICKS_CLIENT_ID: $(downloadSP.secureFilePath)`
   - `DATABRICKS_CLIENT_SECRET: $(downloadSP.secureFilePath)`

## Notes and Tips

- Dependencies: The project uses `uv` and [pyproject.toml](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app/pyproject.toml:0:0-0-0) for Python dependencies (dbt-core, dbt-databricks, sqlfluff, etc.). [deployment/local_setup/setup.sh](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app/deployment/local_setup/setup.sh:0:0-0-0) will install them into an isolated venv.
- dbt packages: Installed via `dbt deps` referencing [databricks-app/dependencies.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/databricks-app/dependencies.yml:0:0-0-0) and shared [common/packages.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/common/packages.yml:0:0-0-0).
- Secrets hygiene:
  - Local: keep service principal JSON in `secrets/databricks-sp.json` (gitignored)
  - CI: use a Secure File; never commit credentials to the repo
- Docker is optional. It's here to provide a reproducible Linux runtime for testing/setup parity. Local token authentication on host is the fastest way to start.

## Optional: Using dbt-osmosis for YAML management

`dbt-osmosis` is installed as a Python dependency for this project, but it is **disabled by default**.
To use it to generate or update your model YAML files in `databricks-app`:

1) Enable the config in `dbt_project.yml` (optional, per-branch):

   - Open `databricks-app/dbt_project.yml`
   - Under `models: databricks_app:`, uncomment:
     ```yaml
     # +dbt-osmosis: "{model}.yml"
     ```

2) Activate your Databricks virtual environment (after running the local setup script):

   ```bash
   cd databricks-app
   source /tmp/venv-databricks-app/bin/activate  # or .venv/bin/activate on non-WSL
   ```

3) Run osmosis to (re)generate YAML files next to your models:

   ```bash
   dbt-osmosis yaml refactor
   ```

4) Review the YAML changes in Git before committing.

As with Databricks, it's recommended to use osmosis on a feature branch so you can easily review and revert YAML changes if needed.
