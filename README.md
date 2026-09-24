# AME

Минимальный локальный state/memory layer для PUB-агентов.

AME зеркалирует нужные метаданные и связи из Notion в локальную SQLite-базу, чтобы Codex и другие агенты не делали повторные широкие запросы к Notion.

## Что внутри

- `notion_sync.py` — bounded sync из Notion.
- `notion_sources.json` — mapping PUB Research Tasks / Implementation Tasks.
- `schema.sql` — SQLite schema + WAL + FTS5.
- `store.py` — локальное хранилище.
- `query.py` — детерминированные запросы для агента.
- `cli.py` — ручная проверка/отладка.
- `bootstrap.ps1` — первый запуск на Windows.
- `test_store.py`, `test_notion_sync.py` — тесты.

## Граница authority

Notion остаётся human-facing authority/control plane.

Локальная SQLite — производное зеркало и быстрый operational index. Она не является вторым источником истины.

Не коммитить:
- `NOTION_TOKEN`;
- `*.db`, `*.db-wal`, `*.db-shm`;
- приватные/customer page bodies.

## Первый запуск на Windows

После клонирования:

```powershell
cd D:\ame
Set-ExecutionPolicy -Scope Process Bypass
.\bootstrap.ps1
```

Скрипт:
1. прогонит тесты;
2. скрыто попросит `NOTION_TOKEN`;
3. создаст БД в `%LOCALAPPDATA%\ame\pub-harness.db`;
4. выполнит первый полный sync;
5. покажет команды проверки.

## Обычная синхронизация после первого запуска

```powershell
python notion_sync.py --db "$env:LOCALAPPDATA\ame\pub-harness.db"
```

Без `--full` используется watermark по `last_edited_time`, поэтому повторный проход забирает только изменившиеся записи.

## Примеры запросов

```powershell
python cli.py --db "$env:LOCALAPPDATA\ame\pub-harness.db" task-get PUB-T-575

python cli.py --db "$env:LOCALAPPDATA\ame\pub-harness.db" task-next --lane local_research --owner "Local Codex" --limit 5

python cli.py --db "$env:LOCALAPPDATA\ame\pub-harness.db" search "Korva"
```

## Текущий scope

v0 зеркалирует:
- PUB Research Tasks;
- PUB Implementation Tasks;
- их явные relations.

Следующие слои: Agent Runs, Claims, Change Events, Change Proposals, lazy page hydration и MCP adapter.
