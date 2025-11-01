# Nanobyte Hugo Site - Dual Build Dockerfile with Go API
# Builds both modern and legacy versions of the site + Go API server

# Stage 1: Build Hugo site
FROM hugomods/hugo:exts AS hugo-builder

WORKDIR /src
COPY . .

# Build modern version
RUN hugo --config config.toml --destination public/modern

# Build legacy version
RUN hugo --config config-legacy.toml --destination public/legacy

# Stage 2: Build Go server
FROM golang:1.21-alpine AS go-builder

WORKDIR /build
COPY go-server/ .

RUN go mod download || true
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .

# Stage 3: Production image with nginx + Go server
FROM nginx:alpine

# Install supervisord to run both nginx and Go server
RUN apk add --no-cache supervisor wget

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built Hugo site from hugo-builder
COPY --from=hugo-builder /src/public /usr/share/nginx/html

# Copy Go server binary and templates from go-builder
COPY --from=go-builder /build/server /app/server
COPY --from=go-builder /build/templates /app/templates

# Copy search index and template to Go server location
COPY --from=hugo-builder /src/public/modern/index.json /app/search-index.json
COPY --from=hugo-builder /src/public/modern/search-template.html /app/search-template.html

# Create supervisord configuration
RUN echo '[supervisord]' > /etc/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisord.conf && \
    echo 'logfile=/dev/null' >> /etc/supervisord.conf && \
    echo 'logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf && \
    echo '[program:nginx]' >> /etc/supervisord.conf && \
    echo 'command=nginx -g "daemon off;"' >> /etc/supervisord.conf && \
    echo 'stdout_logfile=/dev/stdout' >> /etc/supervisord.conf && \
    echo 'stdout_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo 'stderr_logfile=/dev/stderr' >> /etc/supervisord.conf && \
    echo 'stderr_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf && \
    echo '[program:goserver]' >> /etc/supervisord.conf && \
    echo 'command=/app/server' >> /etc/supervisord.conf && \
    echo 'directory=/app' >> /etc/supervisord.conf && \
    echo 'stdout_logfile=/dev/stdout' >> /etc/supervisord.conf && \
    echo 'stdout_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo 'stderr_logfile=/dev/stderr' >> /etc/supervisord.conf && \
    echo 'stderr_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisord.conf

# Expose ports
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Run supervisord to manage both processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
