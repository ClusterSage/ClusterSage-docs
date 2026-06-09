param(
  [string]$MirrorPath = ".terraform-provider-mirror"
)

$ErrorActionPreference = "Stop"

Push-Location (Join-Path $PSScriptRoot "..")
try {
  New-Item -ItemType Directory -Force -Path $MirrorPath | Out-Null
  terraform providers lock -platform=windows_amd64
  terraform providers mirror -platform=windows_amd64 $MirrorPath
  Write-Host "Provider mirror created at: $((Resolve-Path $MirrorPath).Path)"
  Write-Host "Copy this folder to the same terraform/ path on the Zscaler-blocked machine."
}
finally {
  Pop-Location
}
