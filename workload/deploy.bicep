targetScope = 'subscription'

@description('Required. The name of the resource group to deploy')
param resourceGroupName string = 'testcase-rg'

@description('Optional. The location to deploy into')
param location string = deployment().location

module rg '../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'deploy-rg'
  params: {
    name: resourceGroupName
    location: location
  }
}

module vnet '../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'deploy-vnet'
  params: {
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: 'testcaseVnet'
    subnets: [
      {
        addressPrefix: '10.0.0.0/28'
        name: 'sqlSubnet'
        serviceEndpoints: [
          {
            service: 'Microsoft.Sql'
          }
        ]
      }
    ]
  }
  dependsOn: [
    rg
  ]
}

module UAI '../modules/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' =  {
  scope: resourceGroup(resourceGroupName)
  name: 'deploy_uai'
  params: {
    name: 'testcaseUAI'
  }
}

module keyvault '../modules/Microsoft.KeyVault/vaults/deploy.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'deploy-keyvault'
  params: {
    name: 'keyvaultWesleyRabo'
    vaultSku: 'standard'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '89.98.165.103' //me
        }
      ]
    }
    roleAssignments: [
      {
        principalIds: [
          '24bfc44a-550a-49fb-b98d-b398f5eed716'
        ]
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
  }
}

module servers '../modules/Microsoft.Sql/servers/deploy.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'deploy-server'
  params: {
    name: 'testwesleyrabocase1'
    administratorLogin: 'sqlAdmin'
    administratorLoginPassword: '' //enter password and deploy, change password and save in kv
    privateEndpoints: [
      {
        service: 'sqlServer'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
      }
    ]
    databases: [
      {
        name: 'testdb'
        skuName: 'Basic'
        skuTier: 'Basic'
        skuCapacity: 5
        maxSizeBytes: 2147483648
      }
    ]
    primaryUserAssignedIdentityId: '/subscriptions/619ebd19-9b97-466d-ba19-d85e7ccd4fce/resourcegroups/testcase-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/testcaseUAI'
    userAssignedIdentities: {
      '/subscriptions/619ebd19-9b97-466d-ba19-d85e7ccd4fce/resourcegroups/testcase-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/testcaseUAI': {}
    }
  }
  dependsOn: [
    vnet
  ]
}

module factory '../modules/Microsoft.DataFactory/factories/deploy.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'deploy-factory'
  params: {
    name: 'wesley-rabobank-case-factory'
    gitConfigureLater: false
    gitRepoType: 'FactoryGitHubConfiguration'
    gitRepositoryName: 'datafactory'
    gitAccountName: 'wesleyrbk'
    gitCollaborationBranch: 'main'
    gitRootFolder: '/'
    publicNetworkAccess: 'Disabled'
    integrationRuntimes: [
      {
        managedVirtualNetworkName: 'default'
        name: 'AutoResolveIntegrationRuntimeVNET'
        type: 'Managed'
        typeProperties: {
          computeProperties: {
            location: 'AutoResolve'
          }
        }
      }
    ]
    managedPrivateEndpoints: [
      {
        groupId: 'sqlServer'
        name: 'testcaseVnet-testwesleyrabocase1-pe'
        privateLinkResourceId: servers.outputs.resourceId
      }
    ]
    managedVirtualNetworkName: 'default'
    userAssignedIdentities: {
      '/subscriptions/619ebd19-9b97-466d-ba19-d85e7ccd4fce/resourcegroups/testcase-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/testcaseUAI': {}
    }
  }
  dependsOn: [
    vnet
  ]
}
