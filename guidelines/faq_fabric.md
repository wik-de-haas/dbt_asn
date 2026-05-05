# FAQ: Troubleshooting dbt on Microsoft Fabric

This guide covers common issues and questions that may arise when using dbt with Microsoft Fabric.

---

### 1. I can't connect to Fabric. What should I do?

Connection issues are often related to your `profiles.yml` configuration or credentials. Here’s a checklist:

*   **Check `profiles.yml` for Typos**: Verify that the `server`, `database`, and `schema` names are correct and don't have any typos.
*   **Authentication Method**: Ensure you are using the correct authentication method. If you're using a Service Principal, make sure your `client_id`, `client_secret`, and `tenant_id` are correctly set up as environment variables. If you're using `cli` auth, make sure you are logged in via the Azure CLI (`az login`).
*   **Service Principal Permissions**: Confirm that your Service Principal has been granted the necessary permissions (e.g., `Contributor` or `Admin`) on the Fabric Lakehouse.
*   **Network/Firewall**: Check if a firewall or network policy is blocking the connection to the Fabric endpoint on port 1433.
*   **Run `dbt debug`**: The output of `dbt debug` provides detailed information about the connection process and will often point to the exact cause of the failure.

---

### 2. My model won't materialize. What are the possible reasons?

If a model fails during `dbt run` or `dbt build`, check the following:

*   **Check dbt Logs**: The terminal output from dbt is your best source of information. Look for specific SQL errors returned by Fabric.
*   **SQL Syntax Errors**: Fabric's T-SQL endpoint may have slightly different syntax or supported functions compared to other platforms like SQL Server or Synapse. Double-check your model's SQL code for compatibility.
*   **Incorrect `ref()` or `source()`**: Ensure that your model's references point to existing and correctly named models or sources. An upstream model might have failed to build, or a source table may not exist.
*   **Data Type Mismatches**: A common issue is trying to insert data of one type into a column of another type. Check the data types in your source tables and your model's logic.

---

### 3. I'm getting a permission or timeout error. What does it mean?

*   **Permission Errors**: A permission error (e.g., `The user does not have permission to perform this action`) typically means that the identity (user or Service Principal) you are connecting with lacks the required `READ` or `WRITE` permissions on the target schema or tables in the Lakehouse. Verify the permissions in your Fabric workspace.

*   **Timeout Errors**: A timeout error indicates that a query took longer to execute than the allowed time. You can try the following:
    *   **Optimize Your Query**: Review the model's SQL code. Can it be made more efficient? Are there large joins or complex aggregations that can be simplified?
    *   **Increase Timeout Setting**: You can increase the command timeout in your `profiles.yml` file by adding a `timeout_seconds` property to your connection profile. Use this as a last resort, as it's often better to optimize the query itself.

    ```yaml
    dev:
      type: fabric
      # ... other settings
      timeout_seconds: 600 # Increase timeout to 10 minutes
    ```
