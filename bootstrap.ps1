$ErrorActionPreference = 'Stop'

Write-Host '=== AME bootstrap ===' -ForegroundColor Cyan

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw 'Python 3.11+ was not found in PATH. Install Python and restart PowerShell.'
}

Write-Host ''
Write-Host '1/4 Running tests...'
python -m unittest -v
if ($LASTEXITCODE -ne 0) {
    throw 'AME tests failed.'
}

$dbDir = Join-Path $env:LOCALAPPDATA 'ame'
$db = Join-Path $dbDir 'pub-harness.db'
New-Item -ItemType Directory -Force -Path $dbDir | Out-Null
$env:PUB_HARNESS_DB = $db

Write-Host ''
Write-Host '2/4 Enter the Notion token. Input is hidden.'
$secure = Read-Host 'NOTION_TOKEN' -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential('ame', $secure)
$env:NOTION_TOKEN = $credential.GetNetworkCredential().Password

if ([string]::IsNullOrWhiteSpace($env:NOTION_TOKEN)) {
    throw 'NOTION_TOKEN is empty.'
}

Write-Host ''
Write-Host '3/4 First full sync: Notion -> SQLite...'
python notion_sync.py --db $db --full
if ($LASTEXITCODE -ne 0) {
    throw 'Notion sync failed.'
}

Write-Host ''
Write-Host '4/4 Done.' -ForegroundColor Green
Write-Host ('DB: ' + $db)
Write-Host ''
Write-Host 'Check:'
Write-Host ('python cli.py --db "' + $db + '" task-next --lane local_research --owner "Local Codex" --limit 5')
Write-Host ('python cli.py --db "' + $db + '" task-get PUB-T-575')
Write-Host ''
Write-Host 'Next incremental sync:'
Write-Host ('python notion_sync.py --db "' + $db + '"')
