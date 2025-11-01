# Nanobyte Hugo Site - Dual Build Dockerfile
# Builds both modern and legacy versions of the site

FROM hugomods/hugo:exts AS builder

# Set working directory
WORKDIR /src

# Copy source files
COPY . .

# Build modern version
RUN hugo --config config.toml --destination public/modern

# Build legacy version
RUN hugo --config config-legacy.toml --destination public/legacy

# Production image with nginx
FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built site from builder
COPY --from=builder /src/public /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check (using curl which is available in nginx:alpine)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
