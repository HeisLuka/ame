$ErrorActionPreference = "Stop"

Write-Host "=== AME bootstrap ===" -ForegroundColor Cyan

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python не найден в PATH. Установи Python 3.11+ и перезапусти PowerShell."
}

Write-Host ""
Write-Host "1/4 Проверяю тесты..."
python -m unittest -v
if ($LASTEXITCODE -ne 0) {
    throw "Тесты AME не прошли."
}

$dbDir = Join-Path $env:LOCALAPPDATA "ame"
$db = Join-Path $dbDir "pub-harness.db"
New-Item -ItemType Directory -Force -Path $dbDir | Out-Null
$env:PUB_HARNESS_DB = $db

Write-Host ""
Write-Host "2/4 Введи Notion token. Он не будет показан на экране."
$secure = Read-Host "NOTION_TOKEN" -AsSecureString
$env:NOTION_TOKEN = [System.Net.NetworkCredential]::new("", $secure).Password

if ([string]::IsNullOrWhiteSpace($env:NOTION_TOKEN)) {
    throw "Пустой NOTION_TOKEN."
}

Write-Host ""
Write-Host "3/4 Первый полный sync Notion -> SQLite..."
python notion_sync.py --db $db --full
if ($LASTEXITCODE -ne 0) {
    throw "Notion sync завершился ошибкой."
}

Write-Host ""
Write-Host "4/4 Готово." -ForegroundColor Green
Write-Host "DB: $db"
Write-Host ""
Write-Host "Проверка:"
Write-Host "python cli.py --db `"$db`" task-next --lane local_research --owner `"Local Codex`" --limit 5"
Write-Host "python cli.py --db `"$db`" task-get PUB-T-575"
Write-Host ""
Write-Host "Следующие sync без полного сканирования:"
Write-Host "python notion_sync.py --db `"$db`""
