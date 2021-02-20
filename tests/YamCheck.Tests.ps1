Describe 'Get-PolicyResults' {
  BeforeAll {
    Get-Module 'YamCheck' | Remove-Module
    Get-Module 'powershell-yaml' | Remove-Module
    Install-Module -Name 'powershell-yaml' -RequiredVersion '0.4.2' -Force -AllowClobber
    Import-Module 'powershell-yaml'
    Import-Module $PSScriptRoot/../YamCheck.psm1 # Importing psm1 for access to private functions
  }

  It 'Given a yaml template without a property required by policy, returns a failed check' {
    $policyResults = Get-PolicyResults -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults |
      Where-Object { 
        $_.Policy.PolicyName -eq 'Assert-RequiredPropertyExists' -and
        $_.YamlFile.YamlFileName -eq 'bad-template'
      } |
      Select-Object -Expand Result
    $testResult | Should -Be $false
  }

  It 'Given a yaml template with a property required by policy, returns a successful check' {
    $policyResults = Get-PolicyResults -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults |
      Where-Object { 
        $_.Policy.PolicyName -eq 'Assert-RequiredPropertyExists' -and
        $_.YamlFile.YamlFileName -eq 'good-template'
      } |
      Select-Object -Expand Result
    $testResult | Should -Be $true
  }

  It 'Given a yaml template with a property not matching a value required by policy, returns a failed check' {
    $policyResults = Get-PolicyResults -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults |
      Where-Object { 
        $_.Policy.PolicyName -eq 'Assert-SubPropertyEqualsValue' -and
        $_.YamlFile.YamlFileName -eq 'bad-template'
      } |
      Select-Object -Expand Result
    $testResult | Should -Be $false
  }

  It 'Given a yaml template with a property matching a value required by policy, returns a successful check' {
    $policyResults = Get-PolicyResults -PolicyDirectories $PSScriptRoot/test-policies -YamlDirectories $PSScriptRoot/test-yaml
    $testResult = $policyResults |
      Where-Object { 
        $_.Policy.PolicyName -eq 'Assert-SubPropertyEqualsValue' -and
        $_.YamlFile.YamlFileName -eq 'good-template'
      } |
      Select-Object -Expand Result
    $testResult | Should -Be $true
  }
}
