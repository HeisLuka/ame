# AME architecture

AME — локальный operational state layer между Notion и агентами.

```text
Notion
  |
  | bounded incremental sync
  v
SQLite + WAL + FTS5
  |
  | deterministic query API
  v
Codex / local agents
```

## Authority

- Notion остаётся источником истины для task/claim/change-control записей.
- SQLite является derived mirror и быстрым operational index.
- Обычные агентские чтения идут в SQLite.
- Полный Notion scan нужен только для первого заполнения и периодического reconciliation.
- Повторный sync использует watermark по `last_edited_time`.

## Почему пока без vector DB

PUB в основном опирается на точные ID, статусы, owners, gates и relations. Для этого SQLite/FTS5 проще, дешевле и предсказуемее. Embeddings можно добавить позже для длинной исторической evidence-базы.

## Что не хранится в Git

- Notion token;
- live SQLite DB;
- WAL/SHM;
- приватные тела страниц;
- customer data.

## Следующий слой

1. Проверить живой full sync.
2. Добавить Agent Runs.
3. Добавить Claims.
4. Добавить Change Events / Change Proposals.
5. Добавить lazy page hydration.
6. Добавить MCP adapter поверх typed query API.
