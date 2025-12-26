FROM archivebox/archivebox:latest

USER root

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and Caddy using a more direct method
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    ca-certificates \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.repo' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && pip install fastapi uvicorn pydantic \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY api.py .
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh .
RUN chmod +x start.sh

# Ensure the archivebox user owns the /app directory
RUN chown -R archivebox:archivebox /app

USER archivebox
WORKDIR /data
CMD ["/app/start.sh"]
