#Requires -Modules @{ ModuleName="powershell-yaml"; ModuleVersion="0.4.2" }

class Policy {
  [string] $PolicyName
  [ScriptBlock] $PolicyFunction
  [FailureSeverity] $FailureSeverity
}

class PolicyFile {
  [string] $PolicyFile
  [Policy[]] $Policies
}

class YamlFile {
  [string] $YamlFileName
  [Hashtable] $Yaml
}

class PolicyResult {
  [Policy] $Policy
  [YamlFile] $YamlFile
  [boolean] $Result

  [void] RefreshResult() {
    $this.Result = Invoke-Command -ScriptBlock $this.Policy.PolicyFunction -ArgumentList $this.YamlFile.Yaml
  }

  PolicyResult([Policy]$policy, [YamlFile]$yamlFile) {
    $this.Policy = $policy
    $this.YamlFile = $yamlFile
    $this.RefreshResult()
    $this
  }
}

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

  $results = Get-PolicyResults -PolicyDirectories $PolicyDirectories -YamlDirectories $YamlDirectories
  Write-PolicyResults $results
}

function Get-PolicyResults {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $YamlDirectories,
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $PolicyDirectories
  )

  $yamls = Get-YamlFiles $YamlDirectories
  Get-Policies $PolicyDirectories | ForEach-Object {
    $_.Policies | ForEach-Object {
      $policy = $_
      $yamls | ForEach-Object {
        [PolicyResult]::new($policy, $_)
      }
    }
  }
}

function Write-PolicyResults {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [PolicyResult[]] $PolicyResults
  )
  $PolicyResults | ForEach-Object {
    if ($_.Result) {
      [console]::ForegroundColor = "green"
    }
    else {
      switch ($_.Policy.FailureSeverity.severityLevel) {
        'Error'   { [console]::ForegroundColor = "red"; break }
        'Warning' { [console]::ForegroundColor = "yellow"; break }
        default   { [console]::ForegroundColor = "white" }
      }
    }
    "$($_.Policy.PolicyName)...$($_.YamlFile.YamlFileName)...$($_.Result ? 'Passed' : 'Failed')"
  }
  [console]::ForegroundColor = "white"
}

function Get-Policies {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $PolicyDirectories
  )
  $PolicyDirectories | ForEach-Object {
    Get-ChildItem $_ -Include *.psm1 -Recurse | ForEach-Object {
      [PolicyFile]@{
        PolicyFile = $_.BaseName
        Policies   = (Import-Module $_.FullName -PassThru).ExportedFunctions.Values | ForEach-Object {
          [Policy]@{
            PolicyName      = $_.Name
            PolicyFunction  = $_.ScriptBlock
            FailureSeverity = (
              ($_.ScriptBlock.Attributes | Where-Object { $_.TypeId.Name -eq 'FailureSeverity' }).severityLevel ?? 
              [FailureSeverity]::new('Error')
            )
          }
        }
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
      [YamlFile]@{
        YamlFileName = $_.BaseName
        Yaml         = Get-Content $_ | ConvertFrom-Yaml
      }
    }
  }
}
