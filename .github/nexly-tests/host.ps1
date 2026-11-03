param([string]$Phase)
. "$PSScriptRoot\common.ps1"
if ($Phase -eq 'start') {
  Install-Nexly (Join-Path $env:GITHUB_WORKSPACE 'dist\NexlyDesk-windows-x64.exe')
  $p = Launch-Nexly
  $pw = 'NxT' + (Get-Random -Minimum 100000 -Maximum 999999) + 'q'
  Log id ((& $Exe --password $pw | Out-String).Trim())
  $id = Get-Id
  New-Item -ItemType Directory -Force share | Out-Null
  "$id`n$pw" | Out-File -Encoding ascii share\host.txt
  Start-Sleep 5
  Shot '04-host-id-password'
} elseif ($Phase -eq 'wait') {
  # wait for client to report done (artifact "client-done")
  $ok = $false
  for ($i=0; $i -lt 90; $i++) {
    $names = gh api "repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts" --jq '.artifacts[].name'
    if ($names -match 'client-done') { $ok = $true; break }
    if ($i % 5 -eq 0) { Shot ("05-host-during-session-{0:d2}" -f $i) }
    Start-Sleep 10 }
  Shot '06-host-final'
  Collect-AppLogs
  if (-not $ok) { throw 'client never reported done' }
} elseif ($Phase -eq 'uninstall') {
  Uninstall-Nexly
}
