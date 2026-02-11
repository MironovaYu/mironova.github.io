#!/bin/sh
set -e

# ── Seed empty volumes with default data (first run) ──────────
if [ ! -f /app/data/content.json ]; then
    echo "[init] Копирую данные по умолчанию в /app/data/ ..."
    cp -r /defaults-data/* /app/data/
fi

if [ ! -d /app/static/uploads/pages ]; then
    echo "[init] Создаю структуру /app/static/uploads/ ..."
    cp -r /defaults-uploads/uploads/* /app/static/uploads/
fi
# ──────────────────────────────────────────────────────────────

# Configure git identity if not already set
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Сайт:    http://0.0.0.0:4343"
echo "  Админка: http://0.0.0.0:4343/admin/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exec gunicorn \
    --bind 0.0.0.0:4343 \
    --workers 2 \
    --access-logfile - \
    --error-logfile - \
    app:app
