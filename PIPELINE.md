## Setup of Pipeline dependencies
In this section we setup the dev environment dependencies (in the dev subscription) which are needed prior to our sample AzDO pipeline being executed for the dev environment. These dependencies include resource groups, key vault / key vault secrets, and the service principals (SPs) needed by Azure DevOps and Terraform.
The scripts below explicitly use the prefix “dev”. You can make minor tweaks to these scripts to create generic environment agnostic scripts for provisioning of the pipeline dependencies

### Create the key vault resource group and the key vault
```
az group create -n dev-pipeline-dependencies-rg -l northeurope
az keyvault create -n dev-pipeline-secrets-kv -g dev-pipeline-dependencies-rg -l northeurope
```

Make a note of the key vault resource id which will be in the format “/subscriptions/XXXXXXXX-XX86–47XX-X8Xf-XXXXXXXXXX/resourceGroups/dev-pipeline-dependencies-rg/providers/Microsoft.KeyVault/vaults/dev-pipeline-secrets-kv”. We will need this in a subsequent step to give the AzDO dev subscription SP access to this key vault
Create storage account and container where terraform will store the state file for the environment
```
az group create -n dev-terraform-backend-rg -l northeurope

# Create storage account
az storage account create --resource-group dev-terraform-backend-rg --name devterraformbackendsa --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group dev-terraform-backend-rg --account-name devterraformbackendsa --query [0].value -o tsv)

# Create blob container
az storage container create --name terraform-backend-files --account-name devterraformbackendsa --account-key $ACCOUNT_KEY
```
Make a note of the storage account id which will in the format “/subscriptions/XXXXXXXX-XX86–47XX-X8Xf-XXXXXXXXXX/resourceGroups/dev-terraform-backend-rg/providers/Microsoft.Storage/storageAccounts/devterraformbackendsa” . This will be needed when providing the terraform service principal access to the storage account container.

Add the storage account key as a secret in the key vault. This will be read in the AzDO pipeline.
```
az keyvault secret set --vault-name dev-pipeline-secrets-kv --name "tf-backend-sa-access-key" --value "$ACCOUNT_KEY"
```
Create a resource group where terraform will provision the resources
```
az group create -n dev-provisioning-rg -l northeurope
```
Create terraform service principal with required access and add corresponding secrets to key vault
You will need jq installed to execute some of the commands below
The example below just gives the terraform service principal minimal access, you can provide access as per your requirements. When using minimal access as described in this post, if you do not have the “Microsoft.Kusto” provider registered, you may get an error as described in the github issue https://github.com/terraform-providers/terraform-provider-azurerm/issues/4488 . To work around this you can register the provider by executing the az command “az provider register -n Microsoft.Kusto”

```
# Create terraform service principal
TF_SP=$(az ad sp create-for-rbac -n dev-tf-sp --role contributor --scopes "/subscriptions/XXXXXXXX-XX86-47XX-X8Xf-XXXXXXXXXX/resourceGroups/dev-terraform-backend-rg/providers/Microsoft.Storage/storageAccounts/devterraformbackendsa" "/subscriptions/XXXXXXXX-XX86-47XX-X8Xf-XXXXXXXXXX/resourceGroups/dev-provisioning-rg"  )
# Client ID of the service principal
TF_CLIENT_ID=$(echo $TF_SP | jq '.appId' | sed 's/"//g')
# Client secret of the service principal
TF_CLIENT_SECRET=$(echo $TF_SP | jq '.password' | sed 's/"//g')
# Set your tenant ID
TF_TENANT_ID="your-tenant-id"
# Set your subscription ID
TF_SUBSCRIPTION="your-subcription-id"
# Add the values as secrets to key vault
az keyvault secret set --vault-name dev-pipeline-secrets-kv --name "tf-sp-id" --value "$TF_CLIENT_ID"
az keyvault secret set --vault-name dev-pipeline-secrets-kv --name "tf-sp-secret" --value "$TF_CLIENT_SECRET"
az keyvault secret set --vault-name dev-pipeline-secrets-kv --name "tf-tenant-id" --value "$TF_TENANT_ID"
az keyvault secret set --vault-name dev-pipeline-secrets-kv --name "tf-subscription-id" --value "$TF_SUBSCRIPTION"
```

Create a SP for AzDO with access to key vault secrets.
This SP will be used by the AzDO pipeline. We will also create an AzDO service connection using this SP
```
AzDO_SP=$(az ad sp create-for-rbac -n dev-azdo-sp --skip-assignment)
AzDO_CLIENT_ID=$(echo $AzDO_SP | jq '.appId' | sed 's/"//g')
AzDO_CLIENT_SECRET=$(echo $AzDO_SP | jq '.password' | sed 's/"//g')
DEV_SUBSCRIPTION_ID="your-subscription"
DEV_SUBSCRIPTION_NAME="your-subscription-name"
TENANT_ID="your-tenant-id"
```

Now we give the AzDO SP access to get pipeline secrets
Make sure to replace the resource Id of the key vault in the scope argument by your key vault resource id.

```
az role assignment create --assignee $AzDO_CLIENT_ID --scope "/subscriptions/XXXXXXXX-XX86-47XX-X8Xf-XXXXXXXXXX/resourceGroups/dev-pipeline-dependencies-rg/providers/Microsoft.KeyVault/vaults/dev-pipeline-secrets-kv" --role "reader"
az keyvault set-policy --name dev-pipeline-secrets-kv --spn $AzDO_CLIENT_ID --subscription $DEV_SUBSCRIPTION_ID --secret-permissions get
```

Next we need to create an AzDO service connection using the above service principal. To do this from the command like we will need the az azure devops extension. We can also create the service conection using the AzDO portal as shown here. If adding the service connection using the command below, make a note of the SP password value ($AzDO_CLIENT_SECRET), as the command will prompt you for this.
```
az devops service-endpoint azurerm create --azure-rm-service-principal-id $AzDO_CLIENT_ID --azure-rm-subscription-id $DEV_SUBSCRIPTION_ID --azure-rm-subscription-name $DEV_SUBSCRIPTION_NAME --azure-rm-tenant-id $TENANT_ID --name dev-sp --organization "https://dev.azure.com/your-org" --project "your-project"
```
