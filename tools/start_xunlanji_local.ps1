$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$gamePath = Join-Path $projectRoot 'game-client'
$serverPath = Join-Path $projectRoot 'server'
$godotPath = Join-Path (Split-Path -Parent $projectRoot) 'Godot_v4.7.1-stable_win64.exe'
$sessionProcess = $null

if (-not (Test-Path -LiteralPath $godotPath)) {
    Write-Host "Godot was not found: $godotPath" -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}
if (-not (Test-Path -LiteralPath (Join-Path $gamePath 'project.godot'))) {
    Write-Host "Game project was not found: $gamePath" -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}

try {
    $alreadyRunning = $false
    try {
        $health = Invoke-RestMethod -Uri 'http://127.0.0.1:8080/health' -TimeoutSec 1
        $alreadyRunning = [bool]$health.ok
    } catch {
        $alreadyRunning = $false
    }

    if (-not $alreadyRunning -and (Test-Path -LiteralPath (Join-Path $serverPath 'src\websocket-room-server.mjs'))) {
        $sessionProcess = Start-Process -FilePath 'node' -ArgumentList 'src/websocket-room-server.mjs' -WorkingDirectory $serverPath -WindowStyle Hidden -PassThru
        Start-Sleep -Milliseconds 450
    }

    Write-Host 'Launching Xunlanji. The session server started by this launcher stops after the game closes.' -ForegroundColor Cyan
    & $godotPath --path $gamePath
} finally {
    if ($null -ne $sessionProcess -and (Get-Process -Id $sessionProcess.Id -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $sessionProcess.Id -Force
    }
}
