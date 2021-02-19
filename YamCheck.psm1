#Requires -Modules @{ ModuleName="powershell-yaml"; ModuleVersion="0.4.2" }

class FailureSeverity : Attribute {
  [ValidateSet("Error", "Warning", "Information")] [string] $severityLevel

  FailureSeverity([string]$severityLevel) {
    $this.severityLevel = $severityLevel
  }
}

function Assert-YamlPolicies {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $YamlDirectories,
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $PolicyDirectories
  )

  $yamls = Get-YamlFiles $YamlDirectories
  $policies = Get-Policies $PolicyDirectories

  $policies | ForEach-Object {
    $_.Policies | ForEach-Object {
      $policy = $_
      $yamls | ForEach-Object { 
        $checkSplat = @{
          ScriptBlock  = $policy.ScriptBlock
          ArgumentList = $_.Yaml
        }
        @{
          Policy = $policy
          Yaml = $_
          Result = Invoke-Command @checkSplat
        }
      }
    }
  }
}

function Get-Policies {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $PolicyDirectories
  )
  $PolicyDirectories | ForEach-Object {
    Get-ChildItem $_ -Include *.psm1 -Recurse | ForEach-Object {
      [PSCustomObject]@{
        PolicyFile = $_.BaseName
        Policies   = (Import-Module $_.FullName -PassThru).ExportedFunctions.Values
      }
    }
  }
}

function Get-YamlFiles {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $YamlDirectories
  )
  $YamlDirectories | ForEach-Object {
    Get-ChildItem $_ -Include *.yml -Recurse | ForEach-Object {
      @{
        Filepath = $_.BaseName
        Yaml     = Get-Content $_ | ConvertFrom-Yaml
      }
    }
  }
}
