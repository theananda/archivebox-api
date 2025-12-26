FROM archivebox/archivebox:latest

USER root
# Install Caddy and Python dependencies
RUN apt-get update && apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.repo' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update && apt-get install -y caddy \
    && pip install fastapi uvicorn pydantic

WORKDIR /app
COPY api.py .
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh .
RUN chmod +x start.sh

# Switch back to archivebox user for safety
USER archivebox
WORKDIR /data
CMD ["/app/start.sh"]
