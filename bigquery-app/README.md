# BigQuery DBT Project

This dbt project targets Google BigQuery and is designed to work in three ways:
- Local development with OAuth (fastest getting started)
- Local Docker with a service account (container parity)
- Azure DevOps CI using a Secure File (service account; no Docker needed)

The same [profiles.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/bigquery-app/profiles.yml:0:0-0:0) is used in all cases via environment-variable templating.

## Prerequisites

- Python 3.12
- Bash shell (Git Bash/WSL on Windows, macOS/Linux default)
- Google Cloud SDK (for local OAuth only): `gcloud auth application-default login`
- BigQuery project and dataset the account can access

## Profiles and Authentication

[bigquery-app/profiles.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/bigquery-app/profiles.yml:0:0-0:0) is templated:
- `method: "{{ env_var('DBT_METHOD', 'oauth') }}"`
- `project: "{{ env_var('BIGQUERY_PROJECT', 'sdp-dev-465909') }}"`
- `dataset: "{{ env_var('BIGQUERY_DATASET', 'test_bigquery_dbt') }}"`
- `location: "{{ env_var('BIGQUERY_LOCATION', 'europe-west4') }}"`
- `keyfile: "{{ env_var('GOOGLE_APPLICATION_CREDENTIALS', '') }}"`

Modes:
- Local host (OAuth): do not set `DBT_METHOD` (defaults to `oauth`), authenticate with `gcloud`.
- Docker/CI (Service Account): set `DBT_METHOD=service-account` and provide `GOOGLE_APPLICATION_CREDENTIALS` (path to JSON). Optionally set `BIGQUERY_*` if you want to override the defaults.

## Quick Start A: Local development (OAuth on host)

1) Authenticate once:
- `gcloud auth application-default login`

2) Install and set up the project:
- `cd bigquery-app`
- `bash deployment/local_setup/setup.sh`

3) Activate the virtual environment:
- On WSL: `source /tmp/venv-bigquery-app/bin/activate`
- On Linux/macOS (non-WSL): `source .venv/bin/activate`
- On Windows PowerShell: `.venv\Scripts\activate`

4) Run dbt:
- `dbt debug`
- `dbt build`

Notes:
- On WSL, the venv location is `/tmp/venv-bigquery-app` by design.
- If you copied [.pre-commit-config.yaml](cci:7://file:///c:/dev/DCIWorkspace/DBT/fabric-app/.pre-commit-config.yaml:0:0-0:0) into [bigquery-app/](cci:7://file:///c:/dev/DCIWorkspace/DBT/bigquery-app:0:0-0:0), install hooks:
  - `pre-commit install`
  - `pre-commit run -a` (optional)

## Quick Start B: Local Docker (Service Account)

This is optional and mirrors how CI injects credentials at runtime.

1) Create a service account in GCP with BigQuery permissions and download its JSON locally (do NOT commit it). Save as:
- `secrets/gcp-sa.json` (this folder is gitignored)

2) Update or verify [docker-compose.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/docker-compose.yml:0:0-0:0) includes:
- A mount for the JSON:
  - `./secrets/gcp-sa.json:/secrets/gcp-sa.json:ro`
- Minimal environment for BigQuery auth:
  - `DBT_METHOD=service-account`
  - `GOOGLE_APPLICATION_CREDENTIALS=/secrets/gcp-sa.json`
- Optionally also set `BIGQUERY_PROJECT`, `BIGQUERY_DATASET`, `BIGQUERY_LOCATION` to override the defaults from profiles.

3) Build and run a container shell:
- `docker compose build`
- `docker compose run --rm ubuntu-wsl bash`

4) Inside the container:
- `cd bigquery-app`
- `bash deployment/local_setup/setup.sh`
- `source .venv/bin/activate`
- `dbt debug`
- `dbt build`

## Quick Start C: Azure DevOps CI (Service Account Secure File)

A minimal pipeline is provided at:
- [bigquery-app/ci/azure-pipelines.yaml](cci:7://file:///c:/dev/DCIWorkspace/DBT/bigquery-app/ci/azure-pipelines.yaml:0:0-0:0)

It:
- Uses `ubuntu-latest` host
- Downloads a Secure File (your service account JSON)
- Installs `uv` and syncs Python dependencies
- Runs `uv run dbt debug/deps/build` with environment variables:
  - `DBT_METHOD=service-account`
  - `BIGQUERY_PROJECT`, `BIGQUERY_DATASET`, `BIGQUERY_LOCATION`
  - `GOOGLE_APPLICATION_CREDENTIALS=$(downloadSA.secureFilePath)`

Setup steps:
1) In Azure DevOps, upload the JSON to Library > Secure files (e.g., `gcp-sa.json`).
2) Ensure the pipeline task `DownloadSecureFile@1` references that filename.
3) Confirm this env line exists in the job:
   - `GOOGLE_APPLICATION_CREDENTIALS: $(downloadSA.secureFilePath)`

## Notes and Tips

- Dependencies: The project uses `uv` and [pyproject.toml](cci:7://file:///c:/dev/DCIWorkspace/DBT/bigquery-app/pyproject.toml:0:0-0:0) for Python dependencies (dbt-core, dbt-bigquery, sqlfluff, etc.). [deployment/local_setup/setup.sh](cci:7://file:///c:/dev/DCIWorkspace/DBT/fabric-app/deployment/local_setup/setup.sh:0:0-0:0) will install them into an isolated venv.
- dbt packages: Installed via `dbt deps` referencing [bigquery-app/dependencies.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/bigquery-app/dependencies.yml:0:0-0:0) and shared [common/packages.yml](cci:7://file:///c:/dev/DCIWorkspace/DBT/common/packages.yml:0:0-0:0).
- Secrets hygiene:
  - Local: keep service account JSON in `secrets/gcp-sa.json` (gitignored)
  - CI: use a Secure File; never commit credentials to the repo
- Docker is optional. It’s here to provide a reproducible Linux runtime for testing/setup parity. Local OAuth on host is the fastest way to start.

## Optional: Using dbt-osmosis for YAML management

`dbt-osmosis` is installed as a Python dependency in this project, but it is **disabled by default**.
To use it to generate or update your model YAML files:

1) Enable the config in `dbt_project.yml` (optional, per-branch):

   - Open `dbt_project.yml`
   - Under `models: bigquery_app:`, uncomment:
     ```yaml
     # +dbt-osmosis: "{model}.yml"
     ```

2) Activate your virtual environment (see Quick Start A):

   ```bash
   cd bigquery-app
   source /tmp/venv-bigquery-app/bin/activate  # or .venv/bin/activate on non-WSL
   ```

3) Run osmosis to (re)generate YAML files next to your models:

   ```bash
   dbt-osmosis yaml refactor
   ```

4) Review the YAML changes in Git before committing.

It’s recommended to use osmosis on a feature branch so you can easily review and revert changes to YAML if needed.
