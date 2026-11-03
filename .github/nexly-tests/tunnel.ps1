param([string]$Out)
$ErrorActionPreference = 'Stop'
$z = Join-Path $env:TEMP 'bore.zip'
Invoke-WebRequest https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-pc-windows-msvc.zip -OutFile $z
Expand-Archive $z -DestinationPath "$env:TEMP\bore" -Force
$log = "$env:TEMP\bore.log"
Start-Process -FilePath "$env:TEMP\bore\bore.exe" -ArgumentList 'local','21118','--to','bore.pub' -RedirectStandardOutput $log -RedirectStandardError "$log.err" -WindowStyle Hidden
for ($i=0; $i -lt 30; $i++) { Start-Sleep 2; $m = Select-String -Path $log,"$log.err" -Pattern 'bore\.pub:\d+' -ErrorAction SilentlyContinue | Select-Object -First 1; if ($m) { break } }
Get-Content $log,"$log.err" -ErrorAction SilentlyContinue
if (-not $m) { throw 'tunnel failed' }
$ep = $m.Matches[0].Value; Set-Content -Path $Out -Value $ep; Write-Host "endpoint $ep"
$h,$pt = $ep -split ':'
try { $c = New-Object System.Net.Sockets.TcpClient; $c.Connect($h, [int]$pt); Write-Host "public endpoint reachable (self-test)"; $c.Close() } catch { Write-Host "WARN: public endpoint NOT reachable (self-test): $_" }
Get-Content $log,"$log.err" -ErrorAction SilentlyContinue
