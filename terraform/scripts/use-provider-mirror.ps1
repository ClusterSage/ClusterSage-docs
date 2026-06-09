param(
  [string]$MirrorPath = ".terraform-provider-mirror"
)

$ErrorActionPreference = "Stop"

$TerraformDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$MirrorFullPath = Resolve-Path (Join-Path $TerraformDir $MirrorPath)
$ConfigPath = Join-Path $TerraformDir ".terraformrc.local"
$MirrorForTerraform = $MirrorFullPath.Path.Replace("\", "/")

@"
provider_installation {
  filesystem_mirror {
    path    = "$MirrorForTerraform"
    include = ["registry.terraform.io/hashicorp/*"]
  }

  direct {
    exclude = ["registry.terraform.io/hashicorp/*"]
  }
}
"@ | Set-Content -LiteralPath $ConfigPath -NoNewline

Write-Host "Terraform CLI config written to: $ConfigPath"
Write-Host "Run this before terraform init in the same PowerShell session:"
Write-Host "`$env:TF_CLI_CONFIG_FILE = '$ConfigPath'"
