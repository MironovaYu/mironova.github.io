FROM python:3.12-slim

# Git for auto-push
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

COPY . .

# Git safe directory (mounted volume)
RUN git config --global --add safe.directory /app

EXPOSE 4343

ENTRYPOINT ["/app/docker-entrypoint.sh"]
