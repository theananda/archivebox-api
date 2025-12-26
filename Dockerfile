# --- Stage 1: Get the Caddy binary ---
FROM caddy:latest AS caddy_builder

# --- Stage 2: Final ArchiveBox image ---
FROM archivebox/archivebox:latest

USER root

# 1. Copy the Caddy binary from the builder stage
COPY --from=caddy_builder /usr/bin/caddy /usr/bin/caddy

# 2. Install Python dependencies 
# We use pip directly so we don't mess with the system's apt packages
RUN pip install --no-cache-dir fastapi uvicorn pydantic

# 3. Setup our application files
WORKDIR /app
COPY api.py .
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh .
RUN chmod +x start.sh && chown -R archivebox:archivebox /app

# Switch back to the archivebox user
USER archivebox
WORKDIR /data

# Use the absolute path to our start script
CMD ["/app/start.sh"]
