#!/bin/bash

# Initialize ArchiveBox (only sets up if /data is empty)
archivebox init --setup

# Start ArchiveBox UI in background
archivebox server 0.0.0.0:8000 &

# Start the FastAPI Wrapper in background
# We run it from /app where api.py is located
cd /app && uvicorn api:app --host 0.0.0.0 --port 9000 &

# Start Caddy in the foreground to keep the container alive
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
