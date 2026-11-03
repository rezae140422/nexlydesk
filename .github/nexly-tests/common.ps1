$ErrorActionPreference = 'Stop'
$Ev = Join-Path $env:GITHUB_WORKSPACE 'evidence'
New-Item -ItemType Directory -Force $Ev | Out-Null
$InstDir = 'C:\Program Files\NexlyDesk'
$Exe = Join-Path $InstDir 'NexlyDesk.exe'
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
Add-Type @"
using System; using System.Runtime.InteropServices;
public class W { [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int ht,bool r);
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int c);
[StructLayout(LayoutKind.Sequential)] public struct R { public int L,T,Rt,B; }
[DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out R r);
public delegate bool EP(IntPtr h, IntPtr l);
[DllImport("user32.dll")] public static extern bool EnumWindows(EP cb, IntPtr l);
[DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
[DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
[DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, System.Text.StringBuilder s, int n);
public static IntPtr FlutterWin(uint[] pids) {
  IntPtr best = IntPtr.Zero; long area = -1;
  EnumWindows((h, l) => { uint pid; GetWindowThreadProcessId(h, out pid);
    if (Array.IndexOf(pids, pid) < 0 || !IsWindowVisible(h)) return true;
    var sb = new System.Text.StringBuilder(256); GetClassName(h, sb, 256);
    if (sb.ToString() != "FLUTTER_RUNNER_WIN32_WINDOW") return true;
    R r; GetWindowRect(h, out r); long a = (long)(r.Rt-r.L)*(r.B-r.T);
    if (a > area) { area = a; best = h; } return true; }, IntPtr.Zero);
  return best; } }
"@
function Shot($name) {
  $b = [System.Windows.Forms.SystemInformation]::VirtualScreen
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Left, $b.Top, 0, 0, $bmp.Size)
  $bmp.Save((Join-Path $Ev "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Host "screenshot: $name.png"
}
function Log($name, $text) { $text | Out-File -Append -Encoding utf8 (Join-Path $Ev "$name.log"); Write-Host "[$name] $text" }
function Collect-AppLogs() {
  $d = Join-Path $Ev 'app-logs'; New-Item -ItemType Directory -Force $d | Out-Null
  foreach ($r in @("$env:APPDATA\NexlyDesk", 'C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\NexlyDesk', "$env:ProgramData\NexlyDesk")) {
    if (Test-Path $r) { Copy-Item -Recurse -Force $r (Join-Path $d ($r -replace '[:\\ ]','_')) -ErrorAction SilentlyContinue }
  }
}
function Install-Nexly($installer) {
  Log install "running $installer --silent-install"
  $ip = Start-Process -FilePath $installer -ArgumentList '--silent-install' -PassThru
  for ($i=0; $i -lt 90 -and -not (Test-Path $Exe); $i++) { Start-Sleep 2 }
  Start-Sleep 10
  Shot '01-after-install'
  Log install (Get-ChildItem $InstDir -ErrorAction SilentlyContinue | Out-String)
  if (-not (Test-Path $Exe)) { throw "MISSING: $Exe" }
  Log install "OK: $Exe exists"
  if (Test-Path (Join-Path $InstDir 'rustdesk.exe')) { throw 'rustdesk.exe still present in install dir' }
}
function Main-Window() {
  for ($i=0; $i -lt 30; $i++) {
    $p = Get-Process NexlyDesk -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($p) { return $p }; Start-Sleep 2 }
  return $null
}
function WinSize($hwnd) { $r = New-Object W+R; [W]::GetWindowRect($hwnd, [ref]$r) | Out-Null; return "$($r.Rt-$r.L)x$($r.B-$r.T)" }
function IdVisible($p) {
  # UI Automation: look for an on-screen element whose name contains the ID digits
  try {
    Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
    $id = (Run-Cli @('--get-id')) -replace '\D',''
    if (-not $id) { return 'unknown' }
    $root = [System.Windows.Automation.AutomationElement]::FromHandle($script:hw)
    $all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
    if ($all.Count -eq 0) { return 'unknown' }
    foreach ($e in $all) {
      $n = ($e.Current.Name -replace '\D','')
      if ($n -and $n.Contains($id) -and -not $e.Current.IsOffscreen) { return 'yes' }
    }
    return 'no'
  } catch { return 'unknown' }
}
function Launch-Nexly() {
  Start-Process -FilePath $Exe
  Start-Sleep 20
  $p = Main-Window
  if (-not $p) { Shot '02-launch-FAILED'; throw 'NexlyDesk main window not found / process died' }
  Log launch "alive after 20s: pid=$($p.Id) title=$($p.MainWindowTitle)"
  $pids = [uint32[]](Get-Process NexlyDesk | ForEach-Object { [uint32]$_.Id })
  $script:hw = $hw = [W]::FlutterWin($pids)
  if ($hw -eq [IntPtr]::Zero) { $hw = $p.MainWindowHandle }
  Log minsize "flutter main hwnd=$hw (MainWindowHandle=$($p.MainWindowHandle))"
  [W]::ShowWindow($p.MainWindowHandle, 9) | Out-Null
  [W]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
  Start-Sleep 3
  Shot '02-launch-default-size'
  Log minsize ("default size: " + (WinSize $hw) + "; ID visible via UIA: " + (IdVisible $p))
  [W]::MoveWindow($hw, 0, 0, 200, 200, $true) | Out-Null  # app must clamp to its minimum size
  Start-Sleep 3
  Shot '03-launch-minimum-size'
  $sz = WinSize $hw
  $vis = IdVisible $p
  Log minsize "after shrink request to 200x200: $sz; ID visible via UIA: $vis"
  $w,$h = $sz -split 'x' | ForEach-Object { [int]$_ }
  if ($w -lt 700 -or $h -lt 500) { throw "main window shrank to $sz (< 700x500): ID card would be cut off" }
  if ($vis -eq 'no') { throw 'ID text not on screen at minimum size' }
  [W]::MoveWindow($hw, 0, 0, 1000, 640, $true) | Out-Null
  Start-Sleep 2
  return $p
}
function Run-Cli($a) {
  $o = Join-Path $env:TEMP ("cli{0}.txt" -f (Get-Random))
  $p = Start-Process -FilePath $Exe -ArgumentList $a -RedirectStandardOutput $o -PassThru -WindowStyle Hidden
  if (-not $p.WaitForExit(60000)) { $p.Kill() }
  return ((Get-Content $o -ErrorAction SilentlyContinue | Out-String).Trim())
}
function Get-Id() {
  for ($i=0; $i -lt 30; $i++) {
    $id = (Run-Cli @('--get-id'))
    if ($id -match '^\d{8,11}$') { Log id "ID=$id"; return $id }
    Start-Sleep 3 }
  throw "no valid ID from --get-id (got '$id')"
}
function Uninstall-Nexly() {
  Get-Process NexlyDesk -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  $up = Start-Process -FilePath $Exe -ArgumentList '--uninstall' -PassThru
  for ($i=0; $i -lt 60 -and (Test-Path $InstDir); $i++) { Start-Sleep 2 }
  Shot '09-after-uninstall'
  if (Test-Path $InstDir) { throw "Uninstall left $InstDir" }
  Log uninstall "OK: $InstDir removed"
}
