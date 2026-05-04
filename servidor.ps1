# FigurinhaOp — Servidor HTTP via PowerShell
# Funciona em qualquer Windows 10/11 sem instalar nada

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8080

$mimes = @{
    '.html' = 'text/html; charset=utf-8'
    '.json' = 'application/json'
    '.js'   = 'application/javascript'
    '.css'  = 'text/css'
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

while ($listener.IsListening) {
    $ctx      = $listener.GetContext()
    $urlPath  = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ($urlPath -eq '') { $urlPath = 'FigurinhaOp_v8.html' }

    $filePath = Join-Path $root $urlPath
    $res      = $ctx.Response

    if (Test-Path $filePath -PathType Leaf) {
        $ext  = [IO.Path]::GetExtension($filePath).ToLower()
        $mime = if ($mimes.ContainsKey($ext)) { $mimes[$ext] } else { 'application/octet-stream' }
        $bytes = [IO.File]::ReadAllBytes($filePath)
        $res.ContentType      = $mime
        $res.ContentLength64  = $bytes.Length
        $res.StatusCode       = 200
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }

    $res.Close()
}
