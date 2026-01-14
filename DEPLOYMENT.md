# GitHub Actions Deployment Configuration

This repository includes a GitHub Actions workflow to automatically build and deploy the ZavaStorefront .NET application as a container to Azure App Service.

## Required GitHub Secrets

Configure the following secret in your GitHub repository settings (Settings → Secrets and variables → Actions):

### `AZURE_CREDENTIALS`
Azure service principal credentials in JSON format:
```json
{
  "clientId": "your-app-id",
  "clientSecret": "your-password", 
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

To create these credentials, run:
```bash
# First, login to the correct tenant
az login --tenant 72f988bf-86f1-41af-91ab-2d7cd011db47

# Then create the service principal
az ad sp create-for-rbac --name "github-actions" --role contributor --scopes /subscriptions/{subscription-id}
```

**Note**: 
- Replace `{subscription-id}` with your actual Azure subscription ID
- Use the tenant ID from the error message that matches your subscription (either `72f988bf-86f1-41af-91ab-2d7cd011db47` or `16b3c013-d300-468d-ac64-7eda0820b6d3`)

## Required GitHub Variables

Configure the following variables in your GitHub repository settings (Settings → Secrets and variables → Actions):

### Repository Variables
- `AZURE_WEBAPP_NAME` - Name of your Azure App Service (e.g., `app-zava-dev-abc123`)
- `AZURE_CONTAINER_REGISTRY` - Name of your Azure Container Registry (e.g., `acrabc123def`)  
- `AZURE_RESOURCE_GROUP` - Name of your Azure Resource Group (e.g., `rg-zava-dev-westus3`)

## Getting Resource Names

After deploying your infrastructure with `azd up`, you can find these values in the output or by running:

```bash
# Get resource names from your deployment
azd env get-values

# Or query Azure directly
az webapp list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o table
az acr list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o table
```

## Workflow Triggers

The workflow runs on:
- Push to `main` branch
- Pull requests to `main` branch  
- Manual trigger via GitHub Actions UI

## Deployment Process

1. **Build**: Creates Docker image from the .NET 6.0 application
2. **Push**: Uploads image to Azure Container Registry
3. **Deploy**: Updates App Service to use the new container image
4. **Restart**: Ensures the new version is running