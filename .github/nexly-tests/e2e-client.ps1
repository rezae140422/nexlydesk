# Windows CLIENT on a separate runner: connect via the tunnel endpoint, screenshot the session.
param([string]$Endpoint, [string]$Password, [string]$Label, [switch]$ExpectPattern)
. "$PSScriptRoot\common.ps1"
Install-Nexly (Join-Path $env:GITHUB_WORKSPACE 'dist\NexlyDesk-windows-x64.exe')
$p = Launch-Nexly
Get-Process NexlyDesk -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle } | ForEach-Object { [W]::ShowWindow($_.MainWindowHandle, 6) | Out-Null }
function PatternRatio($file) {
  $b = [System.Drawing.Bitmap]::FromFile($file); $n=0; $m=0
  for ($x=0; $x -lt $b.Width; $x+=8) { for ($y=0; $y -lt $b.Height; $y+=8) { $c=$b.GetPixel($x,$y); $n++
    if (($c.R -gt 200 -and $c.G -lt 70 -and $c.B -gt 200) -or ($c.R -lt 70 -and $c.G -gt 200 -and $c.B -gt 200)) { $m++ } } }
  $b.Dispose(); return [math]::Round($m/$n,3)
}
$ok = $false
for ($a=1; $a -le 4 -and -not $ok; $a++) {
  Log client "attempt ${a}: --connect $Endpoint"
  $sp = Start-Process -FilePath $Exe -ArgumentList '--connect', $Endpoint, '--password', $Password -PassThru
  for ($i=1; $i -le 9; $i++) {
    Start-Sleep 5
    $s = Get-Process NexlyDesk -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle } | ForEach-Object { $_.MainWindowTitle }
    Log client ("t={0}s windows: {1}" -f ($i*5), ($s -join ' | '))
  }
  $f = "C$a-$Label-client-session"
  Shot $f
  $r = PatternRatio (Join-Path $Ev "$f.png")
  Log client "attempt ${a} host-pattern pixel ratio in client screenshot: $r"
  Collect-AppLogs
  $err = Get-ChildItem -Recurse (Join-Path $Ev 'app-logs') -File -Filter *.log -ErrorAction SilentlyContinue | Select-String 'Wrong Password|Connection error|Failed to connect|timeout' | Select-Object -Last 3
  Log client ("recent errors: " + ($err | Out-String))
  if ($ExpectPattern) { $ok = $r -ge 0.15 } else { $ok = -not $err -and ((Get-Process NexlyDesk | Where-Object { $_.MainWindowTitle }).Count -ge 1) }
  if (-not $ok) { Get-Process NexlyDesk -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $p.Id -and $_.MainWindowTitle } | Stop-Process -Force -ErrorAction SilentlyContinue; Start-Sleep 10 }
}
Start-Sleep 30; Shot "C9-$Label-client-session-final"
if (-not $ok) { throw "client did not show the remote screen ($Label)" }
Log client "OK: client shows the remote host ($Label)"
Uninstall-Nexly
