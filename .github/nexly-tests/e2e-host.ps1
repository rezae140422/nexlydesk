# Windows HOST for the two-runner direct-IP test.
param([string]$Phase)
. "$PSScriptRoot\common.ps1"
if ($Phase -eq 'start') {
  Install-Nexly (Join-Path $env:GITHUB_WORKSPACE 'dist\NexlyDesk-windows-x64.exe')
  $p = Launch-Nexly
  $id = Get-Id
  $pw = 'NxE' + (Get-Random -Minimum 100000 -Maximum 999999) + 'q'
  Log host ("set password: " + (Run-Cli @('--password', $pw)))
  Start-Sleep 5
  if (-not (Get-NetTCPConnection -LocalPort 21118 -State Listen -ErrorAction SilentlyContinue)) { throw '21118 not listening on host' }
  Set-Content (Join-Path $env:GITHUB_WORKSPACE 'pw.txt') $pw
  Start-Process pwsh -ArgumentList '-NoProfile','-File',"$PSScriptRoot\host-pattern.ps1"
  Start-Sleep 5; Shot 'H1-host-pattern-before-connection'
} else {
  $opened = $null
  for ($i=0; $i -lt 150 -and -not $opened; $i++) {
    Start-Sleep 10
    Collect-AppLogs
    $opened = Get-ChildItem -Recurse (Join-Path $Ev 'app-logs') -File -Filter *.log -ErrorAction SilentlyContinue | Select-String 'Connection opened from' | Select-Object -First 1
  }
  if (-not $opened) { Shot 'H9-no-connection'; throw 'host never got a connection' }
  Log host "HOST: $($opened.Line)"
  Start-Sleep 20; Shot 'H2-host-during-session'
  Start-Sleep 100; Shot 'H3-host-during-session-later'
  Collect-AppLogs
  Get-Process pwsh | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
  Uninstall-Nexly
}
