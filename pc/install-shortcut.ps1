# Creates Desktop + Start Menu shortcuts for JcgTrainer
$here = $PSScriptRoot
$name = [string]::new([char[]]@(0xC815,0xCC98,0xAE30,0x20,0xC2E4,0xAE30,0x20,0xD2B8,0xB808,0xC774,0xB108)) # app display name (Korean)
$ws = New-Object -ComObject WScript.Shell
$targets = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))
foreach ($dir in $targets) {
  $lnk = $ws.CreateShortcut((Join-Path $dir "$name.lnk"))
  $lnk.TargetPath       = "$env:WINDIR\System32\wscript.exe"
  $lnk.Arguments        = "`"$here\start.vbs`""
  $lnk.WorkingDirectory = $here
  $lnk.IconLocation     = "$here\icon.ico,0"
  $lnk.Description      = 'JcgTrainer'
  $lnk.Save()
  Write-Host "created: $dir\$name.lnk"
}
