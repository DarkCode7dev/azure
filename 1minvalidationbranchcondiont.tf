trigger: none 
pool: 'zelectric_pool'
stages:
- stage: TerraformInitAndPlan
  displayName: Terraform Init And Plan
  jobs: 
  - job: TerraformInitAndPlan
    displayName: Terraform Init And Plan
    steps:

    - task: tfsec@1
      inputs:
        version: 'v1.26.0'
        dir: '$(System.DefaultWorkingDirectory)/todoapp_infra'

    - task: TerraformTaskV4@4
      displayName: 'Terraform init'
      inputs:
        provider: 'azurerm'
        command: 'init'
        workingDirectory: '$(System.DefaultWorkingDirectory)/todoapp_infra'
        commandOptions: '-upgrade'
        backendServiceArm: 'devconnection'
        backendAzureRmResourceGroupName: 'BigBadDeves'
        backendAzureRmStorageAccountName: 'bigstorageacc'
        backendAzureRmContainerName: 'bloby'
        backendAzureRmKey: 'terraform.tfstate'

    - task: TerraformTaskV4@4
      displayName: 'Terraform Plan'
      inputs:
        provider: 'azurerm'
        command: 'plan'
        workingDirectory: '$(System.DefaultWorkingDirectory)/todoapp_infra'
        environmentServiceNameAzureRM: 'devconnection'
         
- stage: ValidationAndTerraformApply
  displayName: Validation And TerraformApply
  condition: and(succeeded(), eq(variables['Build.SourceBranchName'],'main'))
  jobs:
  - job: ManualValidation
    pool: server
    steps:
    - task: ManualValidation@1
      inputs:
        notifyUsers: abc@abc.com 
        timeoutInMinutes: 1
  - job: TerraformApply
    dependsOn: ManualValidation
    steps:
    - task: TerraformTaskV4@4
      displayName: 'Terraform init'
      inputs:
        provider: 'azurerm'
        command: 'init'
        workingDirectory: '$(System.DefaultWorkingDirectory)/todoapp_infra'
        commandOptions: '-upgrade'
        backendServiceArm: 'hope'
        backendAzureRmResourceGroupName: 'BigBadDeves'
        backendAzureRmStorageAccountName: 'bigstorageacc'
        backendAzureRmContainerName: 'bloby'
        backendAzureRmKey: 'terraform.tfstate'
    - task: TerraformTaskV4@4
      inputs:
        provider: 'azurerm'
        command: 'apply'
        workingDirectory: '$(System.DefaultWorkingDirectory)/todoapp_infra'
        environmentServiceNameAzureRM: 'devconnection'






