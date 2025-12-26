#!/bin/bash

# 1. Initialize ArchiveBox (Safe to run every time, it won't overwrite existing data)
archivebox init --setup

# 2. Start ArchiveBox UI on port 8000
archivebox server 0.0.0.0:8000 &

# 3. Start the FastAPI Wrapper on port 9000
# We use /app/api.py because that's where we copied it
cd /app && uvicorn api:app --host 0.0.0.0 --port 9000 &

# 4. Start Caddy in the foreground (this keeps the container running)
# Caddy will listen on the Railway $PORT and proxy to 8000 or 9000
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
