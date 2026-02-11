#!/bin/sh
set -e

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
