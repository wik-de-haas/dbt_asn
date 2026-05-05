# Quickstart: Get Your dbt Project Running in 5 Minutes

This guide provides the fastest path to getting the dbt starter for Microsoft Fabric up and running — including a fully automated setup with `setup.sh`.

## Option 1: Run the Automated Setup Script (Recommended for WSL/Linux/macOS)

If you're using **WSL, macOS, or Linux**, you can use `setup.sh` script to install everything: Python dependencies, virtual environment, `uv`, ODBC drivers, and environment variables from `.env`.

### Steps:

1. **Clone the Repository**
```bash
git clone https://dev.azure.com/dci/dbt-community/_git/dbt-starter-fabric ##!!!! Don't forget to replace te right URL!
cd dbt-starter-fabric
```

2. **Run the setup script**

```bash
    ./scripts/setup.sh
```

    If you get a "Permission denied" error, make the script executable:
    ```bash
    chmod +x scripts/setup.sh
    ```

3. **After setup**
   To activate your environment in future terminal sessions:

```bash
   source .venv/bin/activate
```

   And to load environment variables: (optional)

```bash
    #This is based on profile.yml and if you have configured .env file Else follow traditional 'export=..'
    export $(grep -v '^#' .env | grep -E '^(FABRIC_CLIENT_ID|FABRIC_CLIENT_SECRET|FABRIC_TENANT_ID|FABRIC_SERVER|FABRIC_SCHEMA|FABRIC_DATABASE)=' | xargs)
```

## What `setup.sh` Does

The setup script performs the following tasks:

* Verifies if user have 'sudo' access
* Verifies Python 3 installation.
* Installs `uv` packages (if missing).
* Creates a `.venv` using `uv venv`.
* Installs Python dependencies using `uv sync`.
* Installs `unixODBC` and Microsoft ODBC Driver 18 (if running inside WSL/mac/linux).

## Option 2: Manual Setup (Cross-Platform)

If you prefer manual control or you're on **Windows native** (not WSL), follow these steps:

### 1. Clone the Repository

```bash
git clone https://dev.azure.com/dci/dbt-community/_git/dbt-starter-fabric
cd dbt-starter-fabric
```

### 2. Install Python (3.8+)

Download from [python.org/downloads](https://www.python.org/downloads/)
Verify:

```bash
python --version
```

### 3. Install `uv` (Dependency Manager)

Follow instructions from the [official uv documentation](https://astral.sh/docs/uv#installation)

### 4. Create a Virtual Environment

```bash
uv venv
```

Activate it:

```bash
.venv\Scripts\activate
```

Install dependencies:

```bash
uv sync
```

## 5. Install Microsoft ODBC Driver (Required for Windows Users)
If you're running this project on native Windows (outside WSL), you'll need to manually install the Microsoft ODBC Driver for SQL Server, which is required to connect to Microsoft Fabric.

Visit the official Microsoft download page:
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

Choose the latest Microsoft ODBC Driver 18 for SQL Server (or newer).
After installation, verify it appears in ODBC Data Source Administrator > Drivers tab.

## 6. Set Up Your `profiles.yml`

Your `profiles.yml` contains your Microsoft Fabric connection info. You'll need to create this file (If not present already) in your dbt project directory.

See [docs/setup_fabric.md](docs/setup_fabric.md) for full configuration details.

## 6. Test and Run the Project

```bash
dbt debug   # Test your Fabric connection
dbt build   # Run all models and tests
```

## Verify Success

If `dbt build` completes without errors, your project is ready to go. You'll see new tables in your Microsoft Fabric workspace under the schema you configured.

Congratulations! You are now ready to start developing with dbt on Microsoft Fabric.
