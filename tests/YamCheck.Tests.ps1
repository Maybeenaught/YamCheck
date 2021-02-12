Describe 'Assert-YamlPolicies' {
  BeforeAll {
    Get-Module 'YamCheck' | Remove-Module
    Get-Module 'powershell-yaml' | Remove-Module
    Install-Module -Name 'powershell-yaml' -RequiredVersion '0.4.2' -Force -AllowClobber
    Import-Module 'powershell-yaml'
    Import-Module $PSScriptRoot/../YamCheck.psd1
  }

  It 'Given a yaml template without a property required by policy, returns a failed check' {
    $policyResults = Assert-YamlPolicies -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults.Policies |
      Where-Object { $_.PolicyScript.Name -eq 'Assert-RequiredPropertyExists' } |
      Select-Object -Expand Results |
      Where-Object File -eq 'bad-template' |
      Select-Object -Expand Result
    $testResult | Should -Be $false
  }

  It 'Given a yaml template with a property required by policy, returns a successful check' {
    $policyResults = Assert-YamlPolicies -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults.Policies |
      Where-Object { $_.PolicyScript.Name -eq 'Assert-RequiredPropertyExists' } |
      Select-Object -Expand Results |
      Where-Object File -eq 'good-template' |
      Select-Object -Expand Result
    $testResult | Should -Be $true
  }

  It 'Given a yaml template with a property not matching a value required by policy, returns a failed check' {
    $policyResults = Assert-YamlPolicies -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults.Policies |
      Where-Object { $_.PolicyScript.Name -eq 'Assert-SubPropertyEqualsValue' } |
      Select-Object -Expand Results |
      Where-Object File -eq 'bad-template' |
      Select-Object -Expand Result
    $testResult | Should -Be $false
  }

  It 'Given a yaml template with a property matching a value required by policy, returns a successful check' {
    $policyResults = Assert-YamlPolicies -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults.Policies |
      Where-Object { $_.PolicyScript.Name -eq 'Assert-SubPropertyEqualsValue' } |
      Select-Object -Expand Results |
      Where-Object File -eq 'good-template' |
      Select-Object -Expand Result
    $testResult | Should -Be $true
  }
}
