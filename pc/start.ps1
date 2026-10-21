# JcgTrainer PC launcher: serves assets/www on localhost and opens it as an app window.
$ErrorActionPreference = 'Stop'
$Port    = 8787
$Url     = "http://localhost:$Port/index.html"
$Root    = Split-Path -Parent $PSScriptRoot
$Www     = Join-Path $Root 'app\src\main\assets\www'
$UserDir = Join-Path $env:LOCALAPPDATA 'JcgTrainer\browser'   # fixed profile = study data persists

function Find-Browser {
  $c = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
  )
  foreach ($p in $c) { if ($p -and (Test-Path $p)) { return $p } }
  return $null
}
function Open-App {
  $b = Find-Browser
  if (-not $b) { Start-Process $Url; return $null }
  New-Item -ItemType Directory -Force -Path $UserDir | Out-Null
  return Start-Process -FilePath $b -PassThru -ArgumentList @("--app=$Url", "--user-data-dir=`"$UserDir`"", '--window-size=480,900', '--no-first-run', '--no-default-browser-check')
}

# Already running? just open another window.
$inUse = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($inUse) { Open-App | Out-Null; exit }

$mime = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.css'='text/css; charset=utf-8';
           '.json'='application/json; charset=utf-8'; '.md'='text/markdown; charset=utf-8'; '.txt'='text/plain; charset=utf-8';
           '.png'='image/png'; '.svg'='image/svg+xml'; '.ico'='image/x-icon' }

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
$proc = Open-App
$wwwFull = [System.IO.Path]::GetFullPath($Www)

try {
  :outer while ($true) {
    $task = $listener.GetContextAsync()
    while (-not $task.AsyncWaitHandle.WaitOne(500)) {
      if ($proc -and $proc.HasExited) { break outer }   # app window closed -> stop server
    }
    $ctx = $task.Result
    $res = $ctx.Response
    try {
      $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
      if ($rel -eq '') { $rel = 'index.html' }
      $path = [System.IO.Path]::GetFullPath((Join-Path $wwwFull $rel))
      if ($path.StartsWith($wwwFull) -and (Test-Path $path -PathType Leaf)) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $ext = [System.IO.Path]::GetExtension($path).ToLower()
        $res.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
        $res.Headers.Add('Cache-Control', 'no-cache')
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      } else { $res.StatusCode = 404 }
    } catch { $res.StatusCode = 500 }
    finally { $res.Close() }
  }
} finally { $listener.Stop(); $listener.Close() }
