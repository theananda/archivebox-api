#!/bin/bash
# Initialize ArchiveBox if data is empty
archivebox init --setup

# Start ArchiveBox UI in background
archivebox server 0.0.0.0:8000 &

# Start the FastAPI Wrapper in background
uvicorn api:app --host 0.0.0.0 --port 9000 &

# Start Caddy (Main process)
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
