function Assert-RequiredPropertyExists {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)] [Hashtable] $yaml
  )
  $null -ne $yaml.requiredProperty
}

function Assert-SubPropertyEqualsValue {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)] [Hashtable] $yaml
  )
  $yaml.sampleProperty.sampleSubProperty -eq "value"
}
