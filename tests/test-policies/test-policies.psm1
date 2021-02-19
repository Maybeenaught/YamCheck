function Assert-RequiredPropertyExists {
  [FailureSeverity("Error")]
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)] [Hashtable] $yaml
  )
  $null -ne $yaml.requiredProperty
}

function Assert-SubPropertyEqualsValue {
  [FailureSeverity("Warning")]
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)] [Hashtable] $yaml
  )
  $yaml.sampleProperty.sampleSubProperty -eq "value"
}
