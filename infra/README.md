# Azure Infrastructure for ZavaStorefront

This directory contains the Azure infrastructure as code using Bicep templates and Azure Developer CLI (AZD) configuration.

## Architecture Overview

The infrastructure includes the following Azure resources:

- **Resource Group**: Single resource group containing all resources
- **Azure Container Registry (ACR)**: Hosts Docker container images
- **App Service Plan**: Linux-based hosting plan
- **Web App**: App Service configured for container deployment
- **Application Insights**: Application monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging
- **Microsoft Foundry**: AI services for GPT-4 and Phi models
- **RBAC**: Role assignments for secure ACR access

## File Structure

```
infra/
├── main.bicep                    # Root orchestration template
├── main.bicepparam              # Parameters file
└── modules/
    ├── log-analytics.bicep      # Log Analytics Workspace
    ├── application-insights.bicep # Application Insights
    ├── container-registry.bicep  # Azure Container Registry
    ├── app-service-plan.bicep   # App Service Plan
    ├── web-app.bicep           # Web App with container config
    ├── foundry.bicep           # Microsoft Foundry workspace
    └── role-assignments.bicep   # RBAC assignments
```

## Prerequisites

1. **Azure CLI** - [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
2. **Azure Developer CLI (AZD)** - [Install AZD](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
3. **Azure Subscription** with sufficient permissions

## Deployment Instructions

### 1. Initialize AZD

```bash
azd init
```

Select option to scan current directory when prompted.

### 2. Login to Azure

```bash
azd auth login
```

### 3. Preview Infrastructure

```bash
azd provision --preview
```

This will:
- Prompt for environment name (e.g., `dev`, `test`)
- Show planned resources without deploying
- Validate Bicep templates

### 4. Deploy Infrastructure

```bash
azd up
```

This will:
- Provision all Azure resources
- Deploy the application to App Service
- Configure RBAC and monitoring

## Environment Configuration

### Required Environment Variables

- `AZURE_ENV_NAME`: Environment name (dev, test, prod)
- `AZURE_LOCATION`: Azure region (defaults to westus3)
- `AZURE_PRINCIPAL_ID`: Your Azure AD user principal ID (for RBAC)

### Optional Variables

- `AZURE_CONTAINER_REGISTRY_NAME`: Custom ACR name (auto-generated if not provided)

## Security Features

- **No Password Authentication**: Uses Azure RBAC instead of registry passwords
- **Managed Identity**: Web App uses system-assigned managed identity
- **ACR Pull Role**: Managed identity granted AcrPull role on container registry
- **HTTPS Only**: Web App configured to require HTTPS

## Monitoring

- **Application Insights**: Integrated with Web App for telemetry
- **Log Analytics**: Centralized logging for all resources
- **Health Checks**: Built-in App Service monitoring

## Cost Optimization

- **Basic SKUs**: Uses cost-effective SKUs suitable for development
- **Log Retention**: Limited to 30 days to reduce costs
- **Daily Quota**: Log Analytics capped at 1GB daily

## Container Deployment

The Web App is configured to:
- Pull images from the provisioned ACR
- Use managed identity for authentication
- Support containerized .NET applications
- Enable logging and monitoring

## Microsoft Foundry Integration

The infrastructure includes Microsoft Foundry workspace for:
- GPT-4 model access
- Phi model capabilities
- AI service integration

## Troubleshooting

### Common Issues

1. **Region Availability**: Ensure westus3 supports Microsoft Foundry services
2. **Permissions**: Verify you have Contributor role on the subscription
3. **Naming Conflicts**: ACR names must be globally unique
4. **Quota Limits**: Check subscription quotas for the selected region

### Useful Commands

```bash
# Check deployment status
azd provision --preview

# View environment details
azd env get-values

# Clean up resources
azd down

# View logs
azd logs
```

## Next Steps

After successful deployment:

1. **Update Container Image**: Deploy your application container
2. **Configure CI/CD**: Set up GitHub Actions for automated deployment
3. **Monitor Application**: Review Application Insights data
4. **Scale Resources**: Adjust SKUs based on usage

## Support

For issues with this infrastructure:
1. Check the [Azure Developer CLI documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
2. Review [Bicep best practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
3. Consult [App Service containers documentation](https://learn.microsoft.com/azure/app-service/configure-custom-container)