# Connecting to Microsoft Fabric

This guide explains how to configure your `profiles.yml` to connect dbt to Microsoft Fabric.

# Pre-requisites

Before connecting dbt to Microsoft Fabric, ensure you have the following:
Tools Installed
  - Python >= 3.8.10
  - dbt-core and dbt-fabric
  - [ODBC Driver 18 for SQL Server](https://go.microsoft.com/fwlink/?linkid=2307162)

Microsoft Fabric Access
  - Access to a Fabric workspace with a Lakehouse and its SQL Analytics Endpoint enabled
  - Read/write permissions on the Lakehouse

Authentication
  For Service Principal:
  - Azure Entra ID app with Client ID, Client Secret, and Tenant ID
  - App must have access to the workspace
  For CLI (Developement Only):
  - install Azure CLI
  - perform az login

## Finding Your Credentials

To connect to Microsoft Fabric, you'll need the following information from your Fabric workspace:

1.  **Server Hostname**: This is the endpoint for your Fabric Lakehouse. You can find this in the properties of your Lakehouse. It typically looks like `<workspace-name>.datawarehouse.fabric.microsoft.com`.
2.  **Database/Lakehouse Name**: The name of the Lakehouse you want to connect to.
3.  **Port**: The default port is 1433.
4.  **Authentication**: We recommend using Entra ID (formerly Azure Active Directory) Service Principal authentication for production environments. You will need:
    *   Tenant ID
    *   Client ID
    *   Client Secret

For development, you can also use your individual user credentials.

## `profiles.yml` Configuration

Here is an example of how to configure your `profiles.yml` for a Microsoft Fabric connection using a Service Principal.

```yaml
your_project_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server'
      server: '<workspace-name>.datawarehouse.fabric.microsoft.com'
      port: 1433
      database: '<your-lakehouse-name>'
      schema: '<your-schema-name>'
      threads: 1
      authentication: 'ServicePrincipal'
      tenant_id: '<your-tenant-id>'
      client_id: '<your-client-id>'
      client_secret: '<your-client-secret>'
      connection_timeout: 0
      command_timeout: 0
      encrypt: true
      trust_cert: false
      retries: 3
```

*   **Replace** the placeholders (`<your-...>`) with your actual values.
*   **Project name**: Change `your_project_name` to match the `name` field in your `dbt_project.yml`.
*   The `schema` is the default schema where dbt will build your models. It's a good practice to use a unique schema for each developer (e.g., `dbt_john_doe`).

## Platform-Specific Notes

*   **Lakehouse vs. Warehouse**: Microsoft Fabric has both Lakehouses and Warehouses. This starter is configured for a Lakehouse. Be aware of the differences in SQL capabilities and performance characteristics.
*   **SQL Endpoint**: You are connecting to the SQL Analytics Endpoint of the Lakehouse.
*   **Limitations**: As of the current version, there might be certain SQL functions or dbt features that are not fully supported on Fabric. Refer to the official `dbt-fabric` adapter documentation for the latest information on limitations and known issues.
*   **Case Sensitivity**: Be mindful of case sensitivity in object names (tables, schemas), which can differ from other platforms.

## Set Up a .env File (Optional but Recommended)

If your `profiles.yml` or DBT project relies on environment variables (for credentials, servername, etc.), create a .env file in your project root:

```bash
.env

FABRIC_SERVER=servername
FABRIC_DATABASE=lakehousename
FABRIC_SCHEMA=dbt_myschema
FABRIC_CLIENT_ID=myclientid
FABRIC_CLIENT_SECRET=myclientsecret
FABRIC_TENANT_ID=mytenantid
```

## Load Environment Variables

To load these variables into your shell session, you can use the following commands:

```bash
#On macOS/Linux:
export $(grep -v '^#' .env | xargs)
#On Windows PowerShell:

Get-Content .env | ForEach-Object {
    if ($_ -match "^\s*([^#][^=]+)=(.+)$") {
        $name, $value = $matches[1].Trim(), $matches[2].Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

# Load these variables before running dbt commands.
# Do not commit your .env file to version control. It may contain sensitive credentials and should be added to your .gitignore file to keep it secure.
```
