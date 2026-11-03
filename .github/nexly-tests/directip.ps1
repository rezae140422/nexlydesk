. "$PSScriptRoot\common.ps1"
Install-Nexly (Join-Path $env:GITHUB_WORKSPACE 'dist\NexlyDesk-windows-x64.exe')
$p = Launch-Nexly
$id = Get-Id
Shot '04-id-password-default-size'
$def = Run-Cli @('--option', 'direct-server')
$pre = (Get-NetTCPConnection -LocalPort 21118 -State Listen -ErrorAction SilentlyContinue | Out-String).Trim()
Log directip "stored direct-server option = '$def'; 21118 listening by default (no option set): $([bool]$pre)"
if ($env:REQUIRE_DEFAULT_DIRECT -eq '1' -and -not $pre) { throw 'direct IP access (21118) is not enabled by default' }
if (-not $pre) { Log directip (Run-Cli @('--option', 'direct-server', 'Y')); Start-Sleep 10 }
$pw = 'NxT' + (Get-Random -Minimum 100000 -Maximum 999999) + 'q'
Log directip ("set password: " + (Run-Cli @('--password', $pw)))
Start-Sleep 5
$listen = (Get-NetTCPConnection -LocalPort 21118 -State Listen -ErrorAction SilentlyContinue | Out-String)
Log directip "port 21118 listeners:`n$listen"
if (-not $listen.Trim()) { throw 'nothing listening on 21118 (direct IP server not running)' }
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' } | Select-Object -First 1).IPAddress
Log directip "connecting to $ip (runner LAN IP) with password"
Start-Process -FilePath $Exe -ArgumentList '--connect', $ip, '--password', $pw
for ($i=1; $i -le 12; $i++) {
  Start-Sleep 5
  $wins = Get-Process NexlyDesk -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle } | ForEach-Object { $_.MainWindowTitle }
  Log directip ("t={0}s windows: {1}" -f ($i*5), ($wins -join ' | '))
  if ($i -eq 4) { Shot '05-direct-ip-session-20s' }
}
Shot '06-direct-ip-session-60s'
Collect-AppLogs
$all = Get-ChildItem -Recurse (Join-Path $Ev 'app-logs') -File -Filter *.log -ErrorAction SilentlyContinue
$opened = $all | Select-String -Pattern 'Connection opened from' | Select-Object -First 5
$bad = $all | Select-String -Pattern 'Connection closed: |Wrong Password|Connection error|not allowed' | Select-Object -First 10
$good = $all | Select-String -Pattern 'Connection secured|codec|decoder|video' | Select-Object -Last 15
Log directip ("host side:`n" + ($opened | Out-String))
Log directip ("client progress:`n" + ($good | Out-String))
Log directip ("errors:`n" + ($bad | Out-String))
if (-not $opened) { throw 'host never accepted a direct-IP connection' }
if ($bad) { throw 'session reported an error (see directip.log / screenshots)' }
Log directip 'OK: direct-IP session established and stayed open 60s'
Get-Process NexlyDesk -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3
Uninstall-Nexly
