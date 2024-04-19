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
 ┃ ┃ ┃ ┣ 📂dns
 ┃ ┃ ┃ ┣ 📂keyVault
 ┃ ┃ ┃ ┣ 📂logAnalyticsWorkspace
 ┃ ┃ ┃ ┣ 📂managedIdentity
 ┃ ┃ ┃ ┣ 📂networkSecurityGroup
 ┃ ┃ ┃ ┣ 📂publicIpAddress
 ┃ ┃ ┃ ┗ 📂virtualNetwork
 ┃ ┃ ┣ 📜01-foundation.bicep
 ┃ ┃ ┗ 📜02-main.bicep
 ┃ ┗ 📜README.md
 ┗ 📜.gitignore
```

| Folder | Description |
| --- | --- |
| `apiManagement` | Contains the Bicep module for deploying API Management Service |
| `applicationGateway` | Contains the Bicep module for deploying Application Gateway |
| `dns` | Contains the Bicep modules for managing DNS records |
| `keyVault` | Contains the Bicep module for deploying Key Vault |
| `logAnalyticsWorkspace` | Contains the Bicep module for deploying Log Analytics Workspace |
| `managedIdentity` | Contains the Bicep module for deploying Managed Identity |
| `networkSecurityGroup` | Contains the Bicep module for deploying Network Security Group |
| `publicIpAddress` | Contains the Bicep module for deploying Public IP Address |
| `virtualNetwork` | Contains the Bicep module for deploying Virtual Network |

## Modules 🧩
This repository contains several Bicep modules that are used to deploy various Azure resources. These modules are reusable and can be used across different Bicep templates.

## Templates 📝
- `01-foundation.bicep`: This template deploys the foundational resources for the Azure API Management infrastructure.
- `02-main.bicep`: This template deploys the main resources including API Management Service, Application Gateway, and associated DNS records.

## Deployment 🚀
This repository contains two PowerShell scripts that are used to deploy the `01-foundation.bicep` and `02-main.bicep` templates. These scripts take care of setting up the necessary Azure context, validating the Bicep templates, and deploying the resources to Azure.