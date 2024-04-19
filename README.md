# Azure API Management Bicep Deployment

## Overview 🌐
This repository contains the Bicep templates and modules for deploying Azure API Management infrastructure. It includes the foundational resources such as Virtual Network, Network Security Group, Log Analytics Workspace, Application Insights, and Key Vault. It also deploys the main resources including API Management Service, Application Gateway, and associated DNS records.

## Repository Structure 📂
```
📦Azure-API-Management-Bicep
 ┣ 📂infrastructure
 ┃ ┣ 📂bicep
 ┃ ┃ ┣ 📂modules
 ┃ ┃ ┃ ┣ 📂apiManagement
 ┃ ┃ ┃ ┣ 📂applicationGateway
 ┃ ┃ ┃ ┣ 📂applicationInsights
 ┃ ┃ ┃ ┣ 📂dns
 ┃ ┃ ┃ ┣ 📂keyVault
 ┃ ┃ ┃ ┣ 📂logAnalytics
 ┃ ┃ ┃ ┣ 📂managedIdentity
 ┃ ┃ ┃ ┣ 📂networkSecurityGroup
 ┃ ┃ ┃ ┣ 📂privateEndpoint
 ┃ ┃ ┃ ┣ 📂publicIpAddress
 ┃ ┃ ┃ ┗ 📂virtualNetwork
 ┃ ┃ ┣ 📂scripts
 ┃ ┃ ┃ ┣ 📜Deploy-Foundation.ps1
 ┃ ┃ ┃ ┗ 📜Deploy-Main.ps1 
 ┃ ┃ ┣ 📜01-foundation.bicep
 ┃ ┃ ┗ 📜02-main.bicep
 ┃ ┗ 📜README.md
 ┗ 📜.gitignore
```

## Key Vault and Managed Identity 🗝️
The API Management and Application Gateway modules both deploy a User Assigned Managed Identity that is used to grant these services access to the Key Vault deployed by 01-foundation.bicep.  In addition to deploying the Managed Identity, these modules also grant the Azure RBAC role Key Vault Secrets User to the Managed Identity.  This allows the Managed Identity to retrieve the TLS certificate from the Key Vault and use it for the Application Gateway and for API Management to read Named Values from the Key Vault.

## Log Analytics and Diagnostic Logs
The Bicep templates in this repository deploy a Log Analytics Workspace.  A number of the services deployed in this repository have diagnostic settings that are configured to send logs to the Log Analytics Workspace.  The diagnostic settings are configured to send logs to the Log Analytics Workspace for the following services:
- API Management
- Application Gateway
- Key Vault
- Network Security Group
- Public IP Address

## Templates 📝
### 01-foundation.bicep
This template deploys the foundational resources for the Azure API Management infrastructure, including Virtual Network/subnets, Network Security Group, Log Analytics Workspace, Application Insights, and Key Vault.

#### Parameters

| Parameter Name | Description | Type | Default Value |
| --- | --- | --- | --- |
| `workloadName` | The name of the workload | `string` | N/A |
| `environmentSuffix` | The suffix for the environment | `string` | N/A |
| `location` | The Azure region where the resources will be deployed | `string` | N/A |
| `addressPrefixes` | The address prefixes for the virtual network | `array` | N/A |
| `subnetConfigurations` | The configurations for the subnets | `subnetConfigurationsType` | N/A |
| `logAnalyticsRetentionDays` | The number of days to retain logs in Log Analytics | `int` | N/A |
| `deploymentId` | The ID of the deployment | `string` | `substring(newGuid(), 0, 8)` |

### 02-main.bicep
This template deploys the main resources including API Management Service, Application Gateway, and associated DNS records.

#### Parameters

| Parameter Name | Description | Type | Default Value |
| --- | --- | --- | --- |
| `workloadName` | The name of the workload, used the generate resource names in the form of `'${workloadName}-${environmentSuffix}-${resourceTypeAbbreviation}'` | `string` | N/A |
| `environmentSuffix` | The identifier for the environment, used the generate resource names in the form of `'${workloadName}-${environmentSuffix}-${resourceTypeAbbreviation}'` | `string` | N/A |
| `location` | The Azure region where the resources will be deployed | `string` | N/A |
| `vnetName` | The name of the virtual network | `string` | N/A |
| `apimSubnetName` | The name of the subnet for API Management | `string` | N/A |
| `appGwSubnetName` | The name of the subnet for Application Gateway | `string` | N/A |
| `logAnalyticsWorkspaceName` | The name of the Log Analytics Workspace | `string` | N/A |
| `keyVaultName` | The name of the Key Vault | `string` | N/A |
| `apimPublisherEmailAddress` | The email address of the API Management publisher | `string` | N/A |
| `apimPublisherOrganizationName` | The organization name of the API Management publisher | `string` | N/A |
| `apimSkuName` | The SKU name for API Management | `string` | N/A |
| `apimSkuCapacity` | The capacity for API Management SKU | `int` | N/A |
| `apimVnetIntegrationMode` | The integration mode for API Management Virtual Network | `string` | N/A |
| `appGatewayMinInstances` | The minimum number of instances for the Application Gateway | `int` | N/A |
| `appGatewayMaxInstances` | The maximum number of instances for the Application Gateway | `int` | N/A |
| `appGatewaySkuName` | The SKU name for the Application Gateway | `string` | N/A |
| `appGatewayTslCertSecretName` | The secret name for the Application Gateway TLS certificate | `string` | N/A |
| `deploymentId` | The ID of the deployment | `string` | `substring(newGuid(), 0, 8)` |

## Deployment 🚀
This repository contains two PowerzShell scripts that are used to deploy the `01-foundation.bicep` and `02-main.bicep` templates. These scripts take care of setting up the necessary Azure context, validating the Bicep templates, and deploying the resources to Azure.  To deploy these scripts, create parameter files for `01-foundation.bicep` and `02-main.bicep` templates.  Parameter files should be .`bicepparam` format and named as `01-foundation[environment name].parameters.bicep` and `02-main.parameters.bicep`.  The scripts will automatically pick up the parameter files and deploy the resources to Azure.

### Deployment Steps
1. Create parameter files as mentioned above
2. Run Deploy-Foundation.ps1
3. Add your App Gateway/APIM certificate to the new Key Vault resource.  Ensure the certificate name in 02-main parameter file matches the name you use when you import to Key Vault.
4. Run Deploy-Main.ps1

### Example Usage
```powershell
.\Deploy-Foundation.ps1 -ResourceGroupName "myResourceGroup" -EnvironmentName "dev"

.\Deploy-Main.ps1 -ResourceGroupName "myResourceGroup" -EnvironmentName "dev"
```

In this example, `myResourceGroup` is the name of the resource group where you want to deploy the resources, and `dev` is the name of the environment.