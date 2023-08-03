# Azure Deployment Script Documentation

This document provides detailed explanation of an Azure deployment script that involves different Azure services, including resource groups, virtual networks, user-assigned identities, KeyVaults, SQL servers and Data Factories. 

---

## Script Explanation

### Parameters

The script declares two parameters:

- `resourceGroupName`: A required string parameter that specifies the name of the Azure resource group that the resources will be deployed into.
- `location`: An optional string parameter to specify the location in which the resources will be deployed. The default value is the location of the deployment.

### Modules

The script uses several modules to deploy resources into Azure:

1. **Resource Group (rg)**: This module deploys an Azure resource group. The parameters `name` and `location` are defined by the corresponding parameters of the deployment script.

2. **Virtual Network (vnet)**: This module deploys an Azure virtual network into the previously created resource group. It configures one subnet 'sqlSubnet' with a service endpoint for Azure SQL Database.

3. **User-Assigned Identity (UAI)**: This module creates an Azure User-Assigned Managed Identity. The identity is named 'testcaseUAI'.

4. **Key Vault (keyvault)**: This module deploys an Azure Key Vault into the resource group. The Key Vault named 'keyvaultWesleyRabo' has its access policy set to deny by default, but allows access from Azure services and a specific IP address '89.98.165.103'.

5. **SQL Server (servers)**: This module deploys an Azure SQL Server named 'testwesleyrabocase1' with an empty password field. It also deploys a SQL Database named 'testdb'. The module uses private endpoint for accessing the SQL Server. The User Assigned Managed Identity 'testcaseUAI' is set as both the primary identity and user assigned identity for the SQL server.

6. **Data Factory (factory)**: This module deploys an Azure Data Factory named 'wesley-rabobank-case-factory' into the resource group. The Data Factory is linked with a GitHub repository named 'datafactory' owned by the GitHub user 'wesleyrbk'. The data factory also contains a Managed Virtual Network and a Managed Private Endpoint for 'sqlServer'.

The script also declares dependencies between resources to ensure they are deployed in the correct order.

---

## Usage

1. Copy the script into a file with a `.bicep` extension.

2. Open Azure CLI.

3. Navigate to the directory containing the `.bicep` file.

4. Run the command `az deployment sub create --template-file ./<filename>.bicep --parameters resourceGroupName=<resource group name> location=<location>`

Replace `<filename>` with the name of your `.bicep` file, `<resource group name>` with the name of your resource group and `<location>` with the desired Azure region (e.g., 'westus2').

Please note that some parameters are left empty in the deployment script for security reasons. You will need to provide the necessary information (like the administrator password for SQL server) during deployment.
