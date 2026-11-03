param([string]$Out)
$ErrorActionPreference = 'Stop'
$z = Join-Path $env:TEMP 'bore.zip'
Invoke-WebRequest https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-pc-windows-msvc.zip -OutFile $z
Expand-Archive $z -DestinationPath "$env:TEMP\bore" -Force
$log = "$env:TEMP\bore.log"
# start via WMI so the tunnel is not tied to this step's job object (survives the step)
$bat = "$env:TEMP\bore-run.cmd"
Set-Content $bat "@`"$env:TEMP\bore\bore.exe`" local 21118 --to bore.pub > `"$log`" 2>&1" -Encoding ascii
$r = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = "cmd.exe /c `"$bat`"" }
Write-Host "WMI create rc=$($r.ReturnValue) pid=$($r.ProcessId)"
$m = $null
for ($i=0; $i -lt 30; $i++) { Start-Sleep 2; if (Test-Path $log) { $m = Select-String -Path $log -Pattern 'bore\.pub:\d+' | Select-Object -First 1; if ($m) { break } } }
if (Test-Path $log) { Get-Content $log }
if (-not $m) { throw 'tunnel failed' }
$ep = $m.Matches[0].Value; Set-Content -Path $Out -Value $ep; Write-Host "endpoint $ep"
$h,$pt = $ep -split ':'
try { $c = New-Object System.Net.Sockets.TcpClient; $c.Connect($h, [int]$pt); Write-Host "public endpoint reachable (self-test)"; $c.Close() } catch { Write-Host "WARN: public endpoint NOT reachable (self-test): $_" }
if (Test-Path $log) { Get-Content $log }
