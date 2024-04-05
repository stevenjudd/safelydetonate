# Remove Azure VM
function Remove-sjAzureDetonateVm {
  param([string]$UserName)

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

  try {
    if (
      Get-AzResourceGroup -Name $NameRoot -ErrorAction Stop | 
        Remove-AzResourceGroup -ErrorAction Stop -Verbose
    ) {
      Write-Host "Successfully removed VM: $NameRoot" -ForegroundColor Green
    }
  } catch {
    # Wait-Debugger
    # Get-AzVM | Select-Object -Property ResourceGroupName,Name
    # throw $_
    Write-Error "Cannot find and/or remove ResourceGroup: $NameRoot"
    return
  }
} #end function Remove-sjAzureDetonateVm