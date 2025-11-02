# Nanobyte Hugo Site - Dual Build Dockerfile with Go API
# Builds both modern and legacy versions of the site + Go API server

# Stage 0: Preprocess diagrams
FROM python:3.11-alpine AS diagram-preprocessor

WORKDIR /src
COPY . .

# Install Graphviz and Python dependencies
RUN apk add --no-cache graphviz
RUN pip install --no-cache-dir pyyaml

# Preprocess diagrams
RUN python3 preprocess_diagrams.py

# Stage 1: Build Hugo site
FROM hugomods/hugo:exts AS hugo-builder

WORKDIR /src
COPY --from=diagram-preprocessor /src /src

# Copy diagrams to static directory for Hugo
RUN mkdir -p static/diagrams && \
    cp -r generated/diagrams/* static/diagrams/ 2>/dev/null || true

# Build modern version (with server-side LaTeX rendering via Hugo's transform.ToMath)
RUN hugo --config config.toml --contentDir generated/content --destination generated/public/modern

# Build legacy version (with server-side LaTeX rendering via Hugo's transform.ToMath)
RUN hugo --config config-legacy.toml --contentDir generated/content --destination generated/public/legacy

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
COPY --from=hugo-builder /src/generated/public /usr/share/nginx/html

# Copy Go server binary and templates from go-builder
COPY --from=go-builder /build/server /app/server
COPY --from=go-builder /build/templates /app/templates

# Copy search index and template to Go server location
COPY --from=hugo-builder /src/generated/public/modern/index.json /app/search-index.json
COPY --from=hugo-builder /src/generated/public/modern/search-template.html /app/search-template.html

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
