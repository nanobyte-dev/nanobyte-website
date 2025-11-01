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

### Docker Build

The `build.sh` script uses Docker to ensure consistent builds:

```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/src \
  hugomods/hugo:exts \
  hugo --config config.toml --destination public/modern
```

### Server Configuration (Planned)

The dual-build system is designed for nginx user-agent detection:

- Modern browsers → serve `/public/modern/`
- Old browsers (IE8-11, old Firefox) → serve `/public/legacy/`

See `SESSION_CONTEXT.md` for deployment architecture details.

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

## Credits

Built with [Hugo](https://gohugo.io/) - The world's fastest framework for building websites.

Migrated from DokuWiki to Hugo with custom theme development.
