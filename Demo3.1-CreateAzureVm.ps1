# Create VM in Azure

function New-sjAzureWin10Vm {
  param(
    [parameter(Mandatory)]
    [string]$EmailRecipient,
    # add validation for email format
    [parameter(Mandatory)]
    [securestring]$VMLocalAdminSecurePassword,
    # add validation for the password complexity
    [string]$Subscription,
    [string]$VMLocalAdminUser,
    [string]$LocationName,
    [ValidateLength(1, 10)]
    [string]$UserName
  )
  
  $ErrorActionPreference = 'Stop'
  if (!($UserName)) {
    $UserName = switch ($true) {
      $IsLinux {
        $env:USER
      }
      $IsMacOS {
        $env:USER
      }
      $IsWindows {
        $env:USERNAME
      }
      default {
        $env:USERNAME
      }
    }
  }
  $NameRoot = 'W10VM' + $userName
  $ResourceGroupName = "$NameRoot"
  $ResourceGroupTag = @{
    'Supervisor' = 'Da Boss'
    'Manager' = 'Big Boss'
    'Support Group' = 'Digital Security'
    'Application Name' = 'Digital Security Detonate OS'
  }
  $VMName = "$NameRoot"
  $VMSize = 'Standard_B2s'
  $VMPublisherName = 'MicrosoftWindowsDesktop'
  $VMOffer = 'Windows-10'
  $VMSkus = '20h2-pro'
  $VMVersion = 'latest'

  $NetworkName = "$NameRoot-vnet"
  $NICName = "$NameRoot-nic"
  $SubnetName = "$NameRoot-subnet"
  $SubnetAddressPrefix = '10.0.0.0/24'
  $VnetAddressPrefix = '10.0.0.0/24'
  $PublicIpAddress = "$NameRoot-publicip"
  $NetworkSecurityGroupName = "$NameRoot-nsg"

  if (-not (Get-AzSubscription -ErrorAction SilentlyContinue)) {
    throw 'Unable to get Azure Subscription. Please connect using Add-AzAccount.'
  }
  
  Write-Verbose "Setting the AzContext to the '$Subscription' subscription"
  try {
    Set-AzContext -Subscription $Subscription -ErrorAction Stop
  } catch {
    throw "Unable to set the AzContext to $Subscription"
  }
  $getAzVmParam = @{
    'ResourceGroupName' = $ResourceGroupName
    'Name' = $VMName
    'ErrorAction' = 'SilentlyContinue'
  }
  if (Get-AzVM @getAzVmParam) {
    Write-Warning 'VM already exists'
    return
  }

  $GetAzReourceGroupParam = @{
    'Name' = $ResourceGroupName
    'ErrorAction' = 'SilentlyContinue'
  }
  if (Get-AzResourceGroup @GetAzReourceGroupParam) {
    Write-Warning 'ResourceGroup already exists'
  } else {
    $newAzResourceGroupParam = @{
      Name = $ResourceGroupName
      Location = $LocationName
      Tag = $ResourceGroupTag
    }
    New-AzResourceGroup @newAzResourceGroupParam
  }

  #region Create security rules
  # $securityRules = @()
  $priority = 100

  # base params

  $NewAzNetworkSecurityRuleConfigParam = @{
    'Access' = 'Allow' 
    'Protocol' = 'Tcp'
    'Direction' = 'Inbound'
    'SourceAddressPrefix' = 'Internet'
    'SourcePortRange' = '*'
    'DestinationAddressPrefix' = '*'
  }

  # Enable to allow RDP traffic
  $NewAzNetworkSecurityRuleConfigParam.Name = 'rdp-rule'
  $NewAzNetworkSecurityRuleConfigParam.Description = 'Allow RDP'
  $NewAzNetworkSecurityRuleConfigParam.DestinationPortRange = 3389
  $NewAzNetworkSecurityRuleConfigParam.Priority = $priority
  $SecurityRules += New-AzNetworkSecurityRuleConfig @NewAzNetworkSecurityRuleConfigParam
  $priority++
  #endregion Create security rules

  # Apply security rules
  $NewAzNetworkSecurityGroupParam = @{
    'Name' = $NetworkSecurityGroupName
    'ResourceGroupName' = $ResourceGroupName
    'Location' = $LocationName
    'SecurityRules' = $SecurityRules
  }
  $nsg = New-AzNetworkSecurityGroup @NewAzNetworkSecurityGroupParam

  $NewAzVirtualNetworkSubnetConfigParam = @{
    'Name' = $SubnetName
    'AddressPrefix' = $SubnetAddressPrefix
  }
  $SingleSubnet = New-AzVirtualNetworkSubnetConfig @NewAzVirtualNetworkSubnetConfigParam

  $NewAzVirtualNetworkParam = @{
    'Name' = $NetworkName
    'ResourceGroupName' = $ResourceGroupName
    'Location' = $LocationName
    'AddressPrefix' = $VnetAddressPrefix
    'Subnet' = $SingleSubnet
  }
  $Vnet = New-AzVirtualNetwork @NewAzVirtualNetworkParam

  $NewAzPublicIpAddressParam = @{
    'Name' = $PublicIpAddress
    'ResourceGroupName' = $ResourceGroupName
    'AllocationMethod' = 'Static'
    'Location' = $LocationName
  }
  $PublicIp = New-AzPublicIpAddress @NewAzPublicIpAddressParam

  $NewAzNetworkInterfaceParam = @{
    'Name' = $NICName
    'ResourceGroupName' = $ResourceGroupName
    'Location' = $LocationName
    'SubnetId' = $Vnet.Subnets[0].Id
    'PublicIpAddressId' = $PublicIp.Id
    'NetworkSecurityGroupId' = $Nsg.Id
  }
  $NIC = New-AzNetworkInterface @NewAzNetworkInterfaceParam

  $Credential = New-Object System.Management.Automation.PSCredential (
    $VMLocalAdminUser, $VMLocalAdminSecurePassword
  )

  $NewAzVMConfigParam = @{
    'VMName' = $VMName
    'VMSize' = $VMSize
  }
  $VirtualMachine = New-AzVMConfig @NewAzVMConfigParam
  
  $SetAzVMOperatingSystemParam = @{
    'VM' = $VirtualMachine
    'Windows' = $true
    'ComputerName' = $VMName
    'Credential' = $Credential
    'ProvisionVMAgent' = $true
    'EnableAutoUpdate' = $true
  }
  $VirtualMachine = Set-AzVMOperatingSystem @SetAzVMOperatingSystemParam

  $AddAzVMNetworkInterfaceParam = @{
    'VM' = $VirtualMachine
    'Id' = $NIC.Id
  }
  $VirtualMachine = Add-AzVMNetworkInterface @AddAzVMNetworkInterfaceParam
  
  $SetAzVMSourceImageParam = @{
    'VM' = $VirtualMachine
    'PublisherName' = $VMPublisherName
    'Offer' = $VMOffer
    'Skus' = $VMSkus
    'Version' = $VMVersion
  }
  $VirtualMachine = Set-AzVMSourceImage @SetAzVMSourceImageParam

  Write-Host '===========================' -ForegroundColor Green
  Write-Host 'Creating VM. Please wait...'
  Write-Host '===========================' -ForegroundColor Green
  $NewAzVMParam = @{
    'ResourceGroupName' = $ResourceGroupName
    'Location' = $LocationName
    'VM' = $VirtualMachine
    'Verbose' = $true
  }
  New-AzVM @NewAzVMParam
  $NewVm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

  Write-Host '============================' -ForegroundColor Green
  Write-Host 'Creating autoshutdown object'
  Write-Host '============================' -ForegroundColor Green

  # create autoshutdown object
  $search = 'Microsoft\.Compute\/virtualMachines\/'
  $replace = 'microsoft.devtestlab/schedules/shutdown-computevm-'
  $ShutDownResourceId = $NewVm.Id -replace $search, $replace
  $ShutDownResourceProperties = @{
    'Status' = 'Enabled'
    'TaskType' = 'ComputeVmShutdownTask'
    'DailyRecurrence' = @{'time' = '1900' }
    'TimeZoneId' = 'Central Standard Time'
    'NotificationSettings' = @{
      'Status' = 'Enabled'
      'TimeInMinutes' = 30
      'EmailRecipient' = "$EmailRecipient"
      'NotificationLocale' = 'en'
    }
    'TargetResourceId' = $NewVm.Id
  }
  $NewAzResourceParams = @{
    'ResourceId' = $ShutDownResourceId
    'Location' = $LocationName
    'Properties' = $ShutDownResourceProperties
    'Force' = $true
  }
  New-AzResource @NewAzResourceParams

  Write-Host '=================================' -ForegroundColor Green
  Write-Host 'Setting Edge First Run Experience'
  Write-Host '=================================' -ForegroundColor Green

  # Setting Edge First Run Experience
  $vmSetupScript = {
    #New-Item -Path HKLM:\SOFTWARE\Microsoft\Edge -ItemType Directory
    $NewItemPropertyParams1 = @{
      'Path' = 'HKLM:\SOFTWARE\Microsoft\Edge'
      'Name' = 'HideFirstRunExperience'
      'Value' = 1
      'PropertyType' = 'DWORD'
    }
    New-ItemProperty @NewItemPropertyParams1

    $NewItemPropertyParams2 = @{
      'Path' = 'HKLM:\SOFTWARE\Microsoft\Edge'
      'Name' = 'HomepageLocation'
      'Value' = 'about:blank'
      'PropertyType' = 'String'
    }
    New-ItemProperty @NewItemPropertyParams2
  }

  $InvokeAzVMRunCommandParams = @{
    'ResourceGroupName' = $ResourceGroupName
    'Name' = $VMName
    'CommandId' = 'RunPowerShellScript'
    'ScriptString' = $vmSetupScript
  }
  Invoke-AzVMRunCommand @InvokeAzVMRunCommandParams

  # connect via Remote Desktop
  $vmIpAddress = $((Get-AzPublicIpAddress -ResourceName $PublicIpAddress).IpAddress)
  switch ($true) {
    $IsLinux {
      $doneMessage = "Run mstsc and connect as '$VMLocalAdminUser' to $vmIpAddress"
    }
    $IsMacOS {
      $doneMessage = "Run mstsc and connect as '$VMLocalAdminUser' to $vmIpAddress"
    }
    $IsWindows {
      $doneMessage = "Connect as '$VMLocalAdminUser' to $vmIpAddress"
      mstsc /v:$vmIpAddress /prompt
    }
    default {
      $doneMessage = "Connect as '$VMLocalAdminUser' to $vmIpAddress"
      mstsc /v:$vmIpAddress /prompt
    }
  }

  Write-Host $('↓' * $($doneMessage.length)) -ForegroundColor Green
  Write-Host $doneMessage
  Write-Host $('↑' * $($doneMessage.length)) -ForegroundColor Green

  Write-Host ''
  Write-Host 'Remember to run Remove-sjAzureDetonateVm when done to remove the VM' -ForegroundColor Magenta
}

$NewSjAzureWin10VmParam = @{
  'EmailRecipient' = (Read-Host -Prompt 'Enter email to notify about shutdown')
  'VMLocalAdminSecurePassword' = (Read-Host -Prompt 'Enter password for the Admin account' -AsSecureString)
  'Subscription' = 'NotFree'
  'VMLocalAdminUser' = 'vmAdmin'
  'LocationName' = 'southcentralus'
}
New-sjAzureWin10Vm @NewSjAzureWin10VmParam
