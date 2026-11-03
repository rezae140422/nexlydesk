param([string]$Phase)
. "$PSScriptRoot\common.ps1"
if ($Phase -eq 'start') {
  Install-Nexly (Join-Path $env:GITHUB_WORKSPACE 'dist\NexlyDesk-windows-x64.exe')
  $p = Launch-Nexly
  $null = Get-Id
  for ($i=0; $i -lt 90; $i++) {
    $names = gh api "repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts" --jq '.artifacts[].name'
    if ($names -match 'host-id') { break }; Start-Sleep 10 }
  $aid = gh api "repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts" --jq '.artifacts[] | select(.name=="host-id") | .id'
  if (-not $aid) { throw 'host-id artifact never appeared' }
  New-Item -ItemType Directory -Force share | Out-Null
  gh api "repos/$env:GITHUB_REPOSITORY/actions/artifacts/$aid/zip" > share\h.zip
  Expand-Archive -Force share\h.zip share
  $lines = Get-Content share\host.txt
  $hid = $lines[0].Trim(); $pw = $lines[1].Trim()
  Log connect "connecting to $hid"
  $before = @(Get-Process NexlyDesk).Count
  Start-Process -FilePath $Exe -ArgumentList '--connect', $hid, '--password', $pw
  $connected = $false
  for ($i=0; $i -lt 18; $i++) {
    Start-Sleep 5
    $wins = Get-Process NexlyDesk -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle } | ForEach-Object { $_.MainWindowTitle }
    Log connect ("t={0}s windows: {1}" -f (($i+1)*5), ($wins -join ' | '))
    if ($i -eq 5) { Shot '07-client-session' }
  }
  Shot '08-client-session-final'
  Collect-AppLogs
  $logtxt = (Get-ChildItem -Recurse (Join-Path $Ev 'app-logs') -File -ErrorAction SilentlyContinue | Get-Content -ErrorAction SilentlyContinue) -join "`n"
  $hits = ($logtxt -split "`n") | Select-String -Pattern 'Connected, waiting for image|first frame|video decoder|Login succeeded|LoginResponse' | Select-Object -First 20
  Log connect ("log evidence:`n" + ($hits | Out-String))
  if (-not $hits) { throw 'no evidence of an established remote session in client logs' }
  Log connect 'OK: session established'
} elseif ($Phase -eq 'uninstall') {
  Uninstall-Nexly
}
