# Nanobyte Hugo Site

A community-driven technology website focused on operating system development, low-level programming, and computer science education.

**Live site:** [nanobyte.dev](https://nanobyte.dev)

## Project Overview

This is a static site built with [Hugo](https://gohugo.io/) featuring a custom theme designed for technical content. The site includes a unique dual-build system that generates both modern and legacy versions to support a wide range of browsers.

### Key Features

- **Dual-build system** - Modern (CSS3, Flexbox) and Legacy (CSS2.1, floats) versions
- **Custom Nanobyte theme** - Dark purple aesthetic designed for technical content
- **Dual licensing** - MIT for code, CC BY-SA 4.0 for content
- **Syntax highlighting** - Monokai theme via Hugo's Chroma
- **Responsive design** - Mobile-friendly with progressive enhancement
- **Dynamic sidebar** - Auto-expanding navigation based on current section
- **Draft/WIP system** - Built-in support for incomplete articles

## Quick Start

### Prerequisites

- Docker (builds use `hugomods/hugo:exts` image)
- Git

### Local Development

```bash
# Clone the repository
git clone <repository-url>
cd HugoRepo

# Run development server (modern version)
./run-local.sh

# Run development server (legacy version)
./run-local.sh --legacy
```

The development server will be available at http://localhost:1313 with hot reloading enabled.

### Building for Production

```bash
# Build both modern and legacy versions
./build.sh

# Output directories:
# - public/modern/  - Modern build (CSS3, Flexbox)
# - public/legacy/  - Legacy build (CSS2.1, floats)
```

### Docker Deployment

#### Build and Run with Docker

```bash
# Build the Docker image
docker build -t nanobyte-site .

# Run the container
docker run -d -p 8080:80 --name nanobyte nanobyte-site

# Access the site at http://localhost:8080
```

#### Using Docker Compose

```bash
# Build and run production version
docker compose up -d

# Access the site at http://localhost:8080

# View logs
docker compose logs -f

# Stop and remove containers
docker compose down
```

#### Development with Docker Compose

```bash
# Run development server with live reload (modern version)
docker compose --profile dev up dev

# Run development server (legacy version)
docker compose --profile dev up dev-legacy

# Run both development servers simultaneously
docker compose --profile dev up dev dev-legacy
```

The development servers will be available at:
- Modern: http://localhost:1313
- Legacy: http://localhost:1314

## Project Structure

```
HugoRepo/
├── config.toml                 # Modern build configuration
├── config-legacy.toml          # Legacy build configuration
├── LICENSE                     # Dual license (MIT + CC BY-SA 4.0)
├── README.md                   # This file
├── build.sh                    # Build both versions
├── run-local.sh               # Local development server
│
├── content/                    # Site content (Markdown)
│   ├── _index.md              # Homepage
│   ├── building-an-os/        # OS development tutorial series
│   ├── transcripts/           # Video transcripts
│   ├── osdev/                 # OS development resources
│   ├── privacy.md
│   └── sitemap.md
│
├── static/                     # Static assets (served as-is)
│   ├── images/                # Images, logos, screenshots
│   ├── fonts/                 # Custom fonts (if any)
│   └── js/                    # JavaScript files
│
└── themes/nanobyte/           # Custom Hugo theme
    ├── assets/css/            # CSS source files
    │   ├── basic.css          # Base styles and resets
    │   ├── content.css        # Content styling (shared)
    │   ├── design.css.tpl     # Layout/design (template)
    │   ├── structure.css.tpl  # Structure (template)
    │   ├── mobile.css         # Mobile responsive styles
    │   ├── syntax.css         # Chroma syntax highlighting
    │   └── print.css          # Print styles
    │
    ├── layouts/
    │   ├── _default/
    │   │   ├── baseof.html    # Base template
    │   │   ├── single.html    # Single page
    │   │   ├── list.html      # Section listing
    │   │   └── sitemap.html   # Sitemap template
    │   ├── partials/
    │   │   ├── header.html    # Site header
    │   │   ├── footer.html    # Site footer
    │   │   ├── sidebar.html   # Dynamic sidebar navigation
    │   │   └── breadcrumbs.html
    │   └── shortcodes/
    │       ├── code.html      # Code block with filename
    │       └── wip.html       # Work-in-progress banner
    │
    └── theme.toml             # Theme metadata
```

## Configuration

### Modern vs Legacy Builds

The site uses two separate Hugo configurations:

- **`config.toml`** - Modern build with `legacyMode = false`
  - Uses Flexbox for layout
  - CSS3 features (transitions, box-shadow, etc.)
  - Advanced CSS selectors
  - Mobile responsive styles

- **`config-legacy.toml`** - Legacy build with `legacyMode = true`
  - Uses floats and inline-block for layout
  - CSS2.1 compatible features only
  - Simpler selectors for old browsers
  - No mobile-specific styles

### Template CSS System

CSS files ending in `.tpl` are processed as Hugo templates, allowing conditional styling:

```css
.wrapper {
{{- if .Site.Params.legacyMode }}
    /* Legacy: float-based layout */
    overflow: hidden;
{{- else }}
    /* Modern: flexbox layout */
    display: flex;
{{- end }}
}
```

This system eliminates CSS duplication while maintaining both versions from a single source.

## Content Management

### Creating New Content

```bash
# Create a new article
hugo new building-an-os/1-4-your-title.md

# Create a new transcript
hugo new transcripts/building-an-os-4-title.md
```

### Front Matter

All content files use YAML front matter:

```yaml
---
title: "Article Title"
weight: 4              # For ordering in sections
draft: false           # Set to true to hide from production
---
```

### Marking Content as Draft/WIP

**For very incomplete articles:**
```yaml
---
title: "Article Title"
draft: true
---
```

**For mostly-complete articles with WIP sections:**
```markdown
{{< wip >}}
This section is still being written. Other parts are complete.
{{< /wip >}}
```

### Shortcodes

#### Code Block with Filename

```markdown
{{< code file="main.asm" lang="nasm" >}}
org 0x7C00
bits 16
{{< /code >}}
```

#### Work in Progress Banner

```markdown
{{< wip >}}
Custom message about what's incomplete.
{{< /wip >}}
```

## Development Workflow

### CSS Changes

CSS templates (`.tpl` files) are processed during build. After editing CSS:

1. The Hugo dev server will auto-rebuild
2. Hard refresh your browser (Ctrl+Shift+R) to clear cache

### Theme Customization

The Nanobyte theme uses a consistent naming convention:
- IDs: `#nb-header`, `#nb-search`, `#nb-toc`
- Classes: `.nb-logo`, `.nb-nav`

### Testing Both Builds

```bash
# Test modern version
./run-local.sh

# Test legacy version (in another terminal)
./run-local.sh --legacy

# Or build both and test output
./build.sh
cd public/modern && python3 -m http.server 8000
cd public/legacy && python3 -m http.server 8001
```

## Color Scheme

The Nanobyte theme uses a dark purple aesthetic:

- Background: `#1e1a2d` (dark purple)
- Code blocks: `#15121F` (darker purple)
- Accent: `#F0A9B8` (pink)
- Primary purple: `#4e348a`
- Secondary purple: `#2d2842`
- Text: `#ccc` (light gray)
- Border: `#333` (gray)

## Deployment

### Docker Deployment (Recommended)

The project includes a Dockerfile for containerized deployment:

```bash
# Build the image
docker build -t nanobyte-site .

# Run with Docker
docker run -d -p 80:80 --name nanobyte nanobyte-site

# Or use Docker Compose
docker compose up -d
```

The Dockerfile:
- Uses multi-stage build for optimization
- Builds both modern and legacy versions
- Serves via nginx with user-agent detection
- Includes health checks and security headers

### Manual Build

The `build.sh` script uses Docker to ensure consistent builds:

```bash
./build.sh

# Output directories:
# - public/modern/  - Modern build
# - public/legacy/  - Legacy build
```

### Server Configuration

The included `nginx.conf` implements automatic user-agent detection to serve the appropriate version:

#### Browser Detection Rules

**Legacy version** served to:
- Internet Explorer 6-11
- Firefox < 28
- Chrome < 29
- Safari < 9
- Opera < 17 (Presto engine)
- Android Browser < 4.4
- iOS Safari < 9
- Very old browsers (Netscape, Mozilla 1-4)

**Modern version** served to:
- All current browsers (Chrome, Firefox, Safari, Edge)
- Any browser not matching legacy rules

#### Testing User-Agent Detection

The container provides debug endpoints:

```bash
# Check which version your browser would receive
curl http://localhost:8080/version

# Test with specific user agents
curl -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko" \
     http://localhost:8080/version
# Returns: Site version: legacy

# Check the X-Site-Version header
curl -I http://localhost:8080/
# Returns: X-Site-Version: modern
```

#### Additional nginx Features

- Gzip compression for text and web fonts
- Static file caching with 1-year expiry and immutable headers
- Security headers (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)
- Custom 404 handling
- Health check endpoint at `/health`
- Version detection endpoint at `/version`

### Deploying to Production

#### Automated Deployment (GitHub Actions)

**Recommended:** The site automatically deploys when you push to the `main` branch.

**Setup (one-time):**

Configure GitHub Secrets in your repository (`Settings` → `Secrets and variables` → `Actions`):

- `DEPLOY_HOST` - Server hostname (e.g., `srv.tibich.com`)
- `DEPLOY_PORT` - SSH port number (e.g., `22` or custom port)
- `DEPLOY_USER` - SSH username (e.g., `tibi`)
- `DEPLOY_PATH` - Deployment directory (e.g., `~/NewServer/Nanobyte`)
- `SSH_PRIVATE_KEY` - Your SSH private key for authentication

See [.github/DEPLOYMENT.md](.github/DEPLOYMENT.md) for detailed setup instructions.

**Deploy:**
```bash
git push origin main
```

The workflow will:
1. Build the Docker image
2. Transfer to server via SSH
3. Deploy with docker compose
4. Verify deployment

You can also manually trigger deployment from the GitHub Actions tab.

#### Manual Deployment Script

For local testing or manual deployments:

1. Copy the deployment configuration template:
   ```bash
   cp .env.deploy.example .env.deploy
   ```

2. Edit `.env.deploy` with your server details:
   ```bash
   DEPLOY_USER=your-username
   DEPLOY_HOST=nanobyte.dev
   DEPLOY_PATH=/var/www/nanobyte-site
   ```

3. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

This will:
1. Build the Docker image locally
2. Transfer image to server via SSH (`docker save | ssh | docker load`)
3. Copy docker-compose configuration
4. Restart the container
5. Show deployment status

## License

This project uses dual licensing:

- **Code** (HTML, CSS, JavaScript, build scripts): [MIT License](LICENSE)
- **Content** (articles, tutorials, documentation): [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

See the [LICENSE](LICENSE) file for full details.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test both modern and legacy builds
5. Submit a pull request

## Links

- **Website:** [nanobyte.dev](https://nanobyte.dev)
- **YouTube:** [@nanobyte-dev](https://www.youtube.com/@nanobyte-dev)
- **Discord:** [Join our community](https://discord.gg/xNrRVXtsgs)
- **GitHub:** [github.com/nanobyte-dev/nanobyte-website](https://github.com/nanobyte-dev/nanobyte-website)
- **Patreon:** [Support us on Patreon](https://www.patreon.com/nanobyte)

## Credits

Built with [Hugo](https://gohugo.io/) - The world's fastest framework for building websites.

Migrated from DokuWiki to Hugo with custom theme development.
