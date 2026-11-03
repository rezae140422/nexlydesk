# Full-screen, top-most, distinctive test image on the HOST so the client view can't be confused with a mirror.
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$f = New-Object System.Windows.Forms.Form
$f.FormBorderStyle = 'None'; $f.WindowState = 'Maximized'; $f.TopMost = $true; $f.BackColor = [System.Drawing.Color]::Magenta
$f.Add_Paint({ param($s,$e)
  $g = $e.Graphics; $w = $s.ClientSize.Width; $h = $s.ClientSize.Height; $t = 120
  for ($x=0; $x -lt $w; $x+=$t) { for ($y=0; $y -lt $h; $y+=$t) {
    if ((($x+$y)/$t) % 2 -eq 0) { $g.FillRectangle([System.Drawing.Brushes]::Cyan, $x, $y, $t, $t) } } }
  $g.FillRectangle([System.Drawing.Brushes]::Black, 0, [int]($h/2-90), $w, 180)
  $font = New-Object System.Drawing.Font('Arial', 72, [System.Drawing.FontStyle]::Bold)
  $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
  $g.DrawString("NEXLY HOST  $env:COMPUTERNAME", $font, [System.Drawing.Brushes]::Yellow, (New-Object System.Drawing.RectangleF 0, 0, $w, $h), $sf) })
[System.Windows.Forms.Application]::Run($f)
