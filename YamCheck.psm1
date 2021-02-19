#Requires -Modules @{ ModuleName="powershell-yaml"; ModuleVersion="0.4.2" }

function Assert-YamlPolicies {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $YamlDirectories,
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $PolicyDirectories
  )

  $yamls = Get-YamlFiles $YamlDirectories

  $policies = $PolicyDirectories | ForEach-Object {
    $policyDir = $_
    Get-ChildItem $policyDir -Include *.psm1 -Recurse | ForEach-Object { 
      $filePolicies = (Import-Module $_.FullName -PassThru).ExportedFunctions.Values | ForEach-Object {
        $checkFunc = $_
        [PSCustomObject]@{
          PolicyScript = $_
          Results      = $yamls | ForEach-Object { 
            $yaml = $_
            $checkSplat = @{
              ScriptBlock  = $checkFunc.ScriptBlock
              ArgumentList = $yaml.Yaml
            }
            [PSCustomObject]@{
              File   = $yaml.Filepath
              Result = Invoke-Command @checkSplat
            }
          }
        }
      }
      [PSCustomObject]@{
        PolicyFile = $_.BaseName
        Policies   = $filePolicies
      }
    }
  }

  $policies
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
