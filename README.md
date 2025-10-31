# Nanobyte Hugo Site

This is the Hugo source for the Nanobyte website.

## Local Development

### Run development server (modern version)
```bash
./run-local.sh
```

### Run development server (legacy version)
```bash
./run-local.sh --legacy
```

The server will be available at http://localhost:1313 with hot reloading enabled.

### Build for production
```bash
./build.sh
```

This builds both modern and legacy versions:
- `public/modern/` - Modern build with full features
- `public/legacy/` - Legacy build for older browsers

## Directory Structure

```
HugoRepo/
├── content/          # Markdown content files
├── themes/nanobyte/  # Custom Nanobyte theme
├── config.toml       # Modern build configuration
├── config-legacy.toml # Legacy build configuration
├── build.sh          # Production build script
└── run-local.sh      # Local development server
```

## Requirements

- Docker
- Git
