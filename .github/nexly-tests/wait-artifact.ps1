param([string]$Name, [string]$Dest, [int]$Timeout = 1800)
New-Item -ItemType Directory -Force $Dest | Out-Null
for ($t=0; $t -lt $Timeout; $t+=15) {
  $id = gh api "repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts" --jq ".artifacts[]|select(.name==`"$Name`")|.id" 2>$null | Select-Object -First 1
  if ($id) { $z = Join-Path $env:TEMP "$Name.zip"; Invoke-WebRequest -Headers @{Authorization="Bearer $env:GH_TOKEN"} "https://api.github.com/repos/$env:GITHUB_REPOSITORY/actions/artifacts/$id/zip" -OutFile $z; Expand-Archive $z -DestinationPath $Dest -Force; exit 0 }
  Start-Sleep 15
}
throw "timeout waiting for artifact $Name"
