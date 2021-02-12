Describe 'Assert-YamlPolicies' {
  BeforeAll {
    Get-Module YamCheck | Remove-Module
    Import-Module $PSScriptRoot/../YamCheck.psd1
  }

  It 'Given a yaml template without a required property, returns a failed check' {
    $policyResults = Assert-YamlPolicies -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults.Policies |
      Where-Object { $_.PolicyScript.Name -eq 'Assert-RequiredPropertyExists' } |
      Select-Object -Expand Results |
      Where-Object File -eq 'bad-template' |
      Select-Object -Expand Result
    $testResult | Should -Be $false
  }
}
