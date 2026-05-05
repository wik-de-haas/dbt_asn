# Fabric Workspaces for DBT Training

This folder contains all the infrastructure required for deploying Microsoft Fabric workspaces for the DBT training.
This document describes how to set up the workspaces using the Azure DevOps pipeline.

---

## Setup

### Prerequisites

Before running the deployment:

- **Azure Subscription**
  Ensure all participants have an active Azure subscription. This can be verified by looking up their names in the Azure portal.

- **Fabric License**
  Ensure all participants have a Microsoft Fabric license. Licenses can be requested through Serviceplanet or by signing up for a free trial.

- **Trainer Permissions**
  Ensure you, as the trainer, have the correct permissions:
  - Access to the DBT project in Azure DevOps.

---

## Step-by-Step Instructions
1. Go to **Pipelines** in Azure DevOps.
2. Select **All** pipelines.
3. Open:
   **infra-dynamic → deploy-and-destroy-dbt-fabric**
4. Click **Run pipeline**.
5. Provide the required parameters (any unspecified parameters can remain at their default values):

   - **Action**
     - *plan and apply*: Creates the Fabric environments.
     - *plan and destroy*: Cleans up the Fabric environments after the training.

   - **Administration Members**
     Add your email address and, if applicable, co-trainer email addresses. Multiple addresses should be separated by commas.

   - **Trainer Emails (comma-separated)**
     Add your email address and, if applicable, co-trainer email addresses. Multiple addresses should be separated by commas.

   - **Participant Emails (comma-separated)**
     Add the email addresses of all participants, separated by commas.

6. Click **Run**.

---

## Optional Script Configurations

Go to **Repos → Files → infra/fabric-training/[insert_mentioned_tf_file]**

1. Configure what you want to deploy for the participants within `terraform.tfvars`.
   By default, one warehouse per participant is created.
   If you add lakehouses, also add the correct configurations within `main.tf` and `variables.tf`.

2. Adjust the rights for the participants and trainer as needed in `main.tf`.
   (Default roles: Trainers = **Admin**, Participants = **Contributor**)
