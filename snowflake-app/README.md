# Snowflake DBT Project

This dbt project targets Snowflake and is designed to work in three ways:
- Local development with username + password (fastest getting started)
- Local Docker with OAuth (container parity)
- Azure DevOps CI using OAuth (no Docker needed)

The same [profiles.yml](profiles.yml) is used in all cases via environment-variable templating.

## Prerequisites

- Python 3.12
- Bash shell (Git Bash/WSL on Windows, macOS/Linux default)
- Snowflake account and warehouse the account can access
- Snowflake username + password (for local development only)

## Profiles and Authentication

[snowflake-app/profiles.yml](profiles.yml) has two targets:

**dev (username + password):**
- `account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"`
- `user: "{{ env_var('SNOWFLAKE_USER') }}"`
- `password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"`
- `role: "{{ env_var('SNOWFLAKE_ROLE', 'ACCOUNTADMIN') }}"`
- `database: "{{ env_var('SNOWFLAKE_DATABASE', 'DBT_DEV') }}"`
- `warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE', 'DBT_DEV_WH') }}"`
- `schema: "{{ env_var('SNOWFLAKE_SCHEMA', 'BASE') }}"`

**DBT_PROD (OAuth):**
- `account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"`
- `oauth_client_id: "{{ env_var('SNOWFLAKE_OAUTH_CLIENT_ID') }}"`
- `oauth_client_secret: "{{ env_var('SNOWFLAKE_OAUTH_CLIENT_SECRET') }}"`
- `token: "{{ env_var('TOKEN') }}"`

Modes:
- Local host (dev): set `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`. Optionally override `SNOWFLAKE_ROLE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_SCHEMA`.
- Docker/CI (OAuth): set `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_OAUTH_CLIENT_ID`, `SNOWFLAKE_OAUTH_CLIENT_SECRET`, and `TOKEN`.

## Quick Start A: Local development (username + password on host)

1) Set environment variables:
- `export SNOWFLAKE_ACCOUNT="your-account-identifier"`
- `export SNOWFLAKE_USER="your-username"`
- `export SNOWFLAKE_PASSWORD="your-password"`

2) Install and set up the project:
- `cd snowflake-app`
- `bash deployment/local_setup/setup.sh`

3) Activate the virtual environment:
- On WSL: `source /tmp/venv-snowflake-app/bin/activate`
- On Linux/macOS (non-WSL): `source .venv/bin/activate`
- On Windows PowerShell: `.venv\Scripts\activate`

4) Run dbt:
- `dbt debug`
- `dbt build`

Notes:
- On WSL, the venv location is `/tmp/venv-snowflake-app` by design.
- If you have a [.pre-commit-config.yaml](.pre-commit-config.yaml) in `snowflake-app/`, install hooks:
  - `pre-commit install`
  - `pre-commit run -a` (optional)

## Quick Start B: Local Docker (OAuth)

This is optional and mirrors how CI injects credentials at runtime.

1) Set up an OAuth integration in Snowflake and note your client ID, client secret, and token.

2) Verify [docker-compose.yml](../docker-compose.yml) includes a `snowflake` service (it already does) with:
- `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD` (dev target)
- Or `SNOWFLAKE_OAUTH_CLIENT_ID`, `SNOWFLAKE_OAUTH_CLIENT_SECRET`, `TOKEN` (prod target)

3) Build and run a container shell:
- `docker compose build`
- `docker compose run --rm snowflake bash`

4) Inside the container:
- `cd snowflake-app`
- `bash deployment/local_setup/setup.sh`
- `source .venv/bin/activate`
- `dbt debug`
- `dbt build`

## Quick Start C: Azure DevOps CI (OAuth) (till in progress)

A minimal pipeline can be added at:
- `snowflake-app/ci/azure-pipelines.yaml`

It should:
- Use `ubuntu-latest` host
- Install `uv` and sync Python dependencies
- Run `uv run dbt debug/deps/build` with environment variables:
  - `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_OAUTH_CLIENT_ID`, `SNOWFLAKE_OAUTH_CLIENT_SECRET`, `TOKEN`
  - Optionally `SNOWFLAKE_ROLE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_SCHEMA`

Setup steps:
1) In Azure DevOps, store OAuth credentials as pipeline variables or a variable group in Library.
2) Reference them as `$(SNOWFLAKE_OAUTH_CLIENT_ID)` etc. in the pipeline YAML.
3) Set `DBT_TARGET=DBT_PROD` to point dbt at the OAuth target in profiles.yml.

## Notes and Tips

- Dependencies: The project uses `uv` and [pyproject.toml](pyproject.toml) for Python dependencies (dbt-core, dbt-snowflake, sqlfluff, etc.). [deployment/local_setup/setup.sh](deployment/local_setup/setup.sh) will install them into an isolated venv.
- dbt packages: Installed via `dbt deps` referencing [snowflake-app/dependencies.yml](dependencies.yml).
- Secrets hygiene:
  - Local: keep credentials in environment variables only, never in committed files
  - CI: use Azure DevOps variable groups or secret variables; never commit credentials to the repo
- Docker is optional. It's here to provide a reproducible Linux runtime for testing/setup parity. Local username/password authentication on host is the fastest way to start.

## Optional: Using dbt-osmosis for YAML management

`dbt-osmosis` is installed as a Python dependency for this project, but it is **disabled by default**.
To use it to generate or update your model YAML files in `snowflake-app`:

1) Enable the config in `dbt_project.yml` (optional, per-branch):

   - Open `snowflake-app/dbt_project.yml`
   - Under `models: snowflake_app:`, uncomment:
     ```yaml
     # +dbt-osmosis: "{model}.yml"
     ```

2) Activate your Snowflake virtual environment (after running the local setup script):

   ```bash
   cd snowflake-app
   source /tmp/venv-snowflake-app/bin/activate  # or .venv/bin/activate on non-WSL
   ```

3) Run osmosis to (re)generate YAML files next to your models:

   ```bash
   dbt-osmosis yaml refactor
   ```

4) Review the YAML changes in Git before committing.

It's recommended to use osmosis on a feature branch so you can easily review and revert YAML changes if needed.
