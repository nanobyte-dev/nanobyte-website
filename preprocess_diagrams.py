#!/usr/bin/env python3
"""
Graphviz Diagram Preprocessor for Hugo
Scans markdown files for ```dot code blocks and converts them to SVG diagrams.
"""

import os
import re
import subprocess
import hashlib
import sys
import yaml
from pathlib import Path

# Configuration
CONTENT_DIR = "content"
GENERATED_CONTENT_DIR = "generated/content"
GENERATED_DIAGRAMS_DIR = "generated/diagrams"
CONFIG_FILE = "diagram_config.yml"
DOT_PATTERN = re.compile(r'```dot\n(.*?)```', re.DOTALL)


def load_config():
    """
    Load configuration from YAML file.

    Returns:
        Dictionary with configuration, or default config if file doesn't exist
    """
    default_config = {
        'theme': {
            'background': '#2d2842',
            'node_fill': '#1e1a2d',
            'node_stroke': '#4e348a',
            'text_color': '#eee',
            'accent_color': '#F0A9B8',
            'edge_color': '#F0A9B8',
        },
        'fonts': {
            'node_font': 'Inter',
            'edge_font': 'Inter',
            'graph_font': 'Arimo',
            'node_fontsize': 12,
            'edge_fontsize': 10,
            'graph_fontsize': 14,
        },
        'graph': {
            'bgcolor': 'transparent',
            'dpi': 96,
        },
        'node': {
            'shape': 'box',
            'style': 'rounded,filled',
            'penwidth': '1.5',
        },
        'edge': {
            'arrowhead': 'vee',
            'penwidth': '1.5',
            'style': 'solid',
        },
        'processing': {
            'cache': True,
            'force_regenerate': False,
            'verbose': False,
        }
    }

    if not os.path.exists(CONFIG_FILE):
        return default_config

    try:
        with open(CONFIG_FILE, 'r') as f:
            config = yaml.safe_load(f)
        return config if config else default_config
    except Exception as e:
        print(f"Warning: Could not load config file: {e}", file=sys.stderr)
        return default_config


def ensure_dirs():
    """Create the necessary directories if they don't exist."""
    Path(GENERATED_DIAGRAMS_DIR).mkdir(parents=True, exist_ok=True)
    Path(GENERATED_CONTENT_DIR).mkdir(parents=True, exist_ok=True)


def apply_theme_to_dot(dot_code, config):
    """
    Apply theme configuration to DOT code by injecting graph/node/edge attributes.

    Args:
        dot_code: Original DOT code
        config: Configuration dictionary

    Returns:
        Modified DOT code with theme applied
    """
    def format_attr_value(value):
        """Format an attribute value, quoting strings if needed."""
        if isinstance(value, str):
            # Already quoted values or numeric-looking strings
            if value.startswith('"') and value.endswith('"'):
                return value
            # Check if it looks like a number
            try:
                float(value)
                return f'"{value}"'  # Still quote it for consistency
            except ValueError:
                return f'"{value}"'
        return str(value)

    graph_attrs = []
    node_attrs = []
    edge_attrs = []

    # Apply graph-level attributes
    graph_cfg = config.get('graph', {})
    if graph_cfg.get('bgcolor'):
        graph_attrs.append(f'bgcolor={format_attr_value(graph_cfg["bgcolor"])}')
    if graph_cfg.get('dpi'):
        graph_attrs.append(f'dpi={graph_cfg["dpi"]}')

    # Apply graph spacing attributes
    for attr_name, attr_value in graph_cfg.get('attributes', {}).items():
        graph_attrs.append(f'{attr_name}={format_attr_value(attr_value)}')

    # Apply graph fonts
    fonts = config.get('fonts', {})
    if fonts.get('graph_font'):
        graph_attrs.append(f'fontname={format_attr_value(fonts["graph_font"])}')
    if fonts.get('graph_fontsize'):
        graph_attrs.append(f'fontsize={fonts["graph_fontsize"]}')

    # Apply node attributes from config
    theme = config.get('theme', {})
    node_cfg = config.get('node', {})

    node_attr_map = {
        'shape': node_cfg.get('shape'),
        'style': node_cfg.get('style'),
        'fillcolor': theme.get('node_fill'),
        'color': theme.get('node_stroke'),
        'fontcolor': theme.get('text_color'),
        'fontname': fonts.get('node_font'),
        'fontsize': fonts.get('node_fontsize'),
        'penwidth': node_cfg.get('penwidth'),
        'margin': node_cfg.get('margin'),
        'width': node_cfg.get('width'),
        'height': node_cfg.get('height'),
    }

    for attr_name, attr_value in node_attr_map.items():
        if attr_value is not None:
            if isinstance(attr_value, str) and not attr_name in ['width', 'height', 'penwidth', 'fontsize']:
                node_attrs.append(f'{attr_name}={format_attr_value(attr_value)}')
            else:
                node_attrs.append(f'{attr_name}={attr_value}')

    # Apply edge attributes from config
    edge_cfg = config.get('edge', {})

    edge_attr_map = {
        'color': theme.get('edge_color'),
        'fontcolor': theme.get('edge_color'),
        'fontname': fonts.get('edge_font'),
        'fontsize': fonts.get('edge_fontsize'),
        'arrowhead': edge_cfg.get('arrowhead'),
        'penwidth': edge_cfg.get('penwidth'),
        'style': edge_cfg.get('style'),
    }

    for attr_name, attr_value in edge_attr_map.items():
        if attr_value is not None:
            if isinstance(attr_value, str) and not attr_name in ['penwidth', 'fontsize', 'arrowhead']:
                edge_attrs.append(f'{attr_name}={format_attr_value(attr_value)}')
            else:
                edge_attrs.append(f'{attr_name}={attr_value}')

    # Parse the DOT code to inject attributes
    # We need to inject AFTER existing graph/node/edge declarations to override them
    # Find the last graph/node/edge attribute line, or right after the opening brace
    lines = dot_code.strip().split('\n')
    modified_lines = []
    injected = False
    graph_started = False
    last_attr_line_idx = -1

    # First pass: find where to inject
    for i, line in enumerate(lines):
        stripped = line.strip()
        # Check if graph/digraph has started
        if not graph_started and '{' in line and ('graph' in line.lower() or 'digraph' in line.lower()):
            graph_started = True
            last_attr_line_idx = i
        # Track the last line with graph/node/edge attributes
        elif graph_started and not injected:
            if (stripped.startswith('graph [') or
                stripped.startswith('node [') or
                stripped.startswith('edge [') or
                stripped.startswith('rankdir') or
                stripped.startswith('ranksep') or
                stripped.startswith('nodesep')):
                last_attr_line_idx = i

    # Second pass: inject at the right location
    for i, line in enumerate(lines):
        modified_lines.append(line)
        # Inject after the last attribute line (or opening brace if no attrs found)
        if not injected and i == last_attr_line_idx:
            if graph_attrs:
                modified_lines.append('    graph [' + ', '.join(graph_attrs) + '];')
            if node_attrs:
                modified_lines.append('    node [' + ', '.join(node_attrs) + '];')
            if edge_attrs:
                modified_lines.append('    edge [' + ', '.join(edge_attrs) + '];')
            injected = True

    return '\n'.join(modified_lines)


def generate_svg_from_dot(dot_code, output_path, config):
    """
    Generate an SVG file from DOT code using Graphviz.

    Args:
        dot_code: The Graphviz DOT language code
        output_path: Where to save the generated SVG
        config: Configuration dictionary

    Returns:
        True if successful, False otherwise
    """
    try:
        # Apply theme to DOT code
        themed_dot = apply_theme_to_dot(dot_code, config)

        # Run dot command to generate SVG
        result = subprocess.run(
            ['dot', '-Tsvg'],
            input=themed_dot.encode('utf-8'),
            capture_output=True,
            check=True
        )

        # Write SVG to file
        with open(output_path, 'wb') as f:
            f.write(result.stdout)

        return True
    except subprocess.CalledProcessError as e:
        print(f"Error generating SVG: {e}", file=sys.stderr)
        print(f"stderr: {e.stderr.decode('utf-8')}", file=sys.stderr)
        return False
    except FileNotFoundError:
        print("Error: 'dot' command not found. Please install Graphviz.", file=sys.stderr)
        return False


def process_markdown_file(source_path, dest_path, config):
    """
    Process a single markdown file, generating SVG diagrams and replacing dot blocks.

    This reads from the source file and writes the processed version to dest_path.
    Source files are never modified.

    Args:
        source_path: Path to the source markdown file
        dest_path: Path where the processed markdown should be written
        config: Configuration dictionary

    Returns:
        Number of diagrams processed
    """
    with open(source_path, 'r', encoding='utf-8') as f:
        content = f.read()

    matches = list(DOT_PATTERN.finditer(content))
    if not matches:
        # No diagrams, just copy the file as-is
        with open(dest_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return 0

    modified_content = content
    diagrams_processed = 0
    processing_cfg = config.get('processing', {})

    # Process matches in reverse order to maintain string positions
    for match in reversed(matches):
        dot_code = match.group(1).strip()

        # Generate a hash-based filename for the diagram
        code_hash = hashlib.md5(dot_code.encode('utf-8')).hexdigest()[:12]
        svg_filename = f"diagram_{code_hash}.svg"
        svg_path = os.path.join(GENERATED_DIAGRAMS_DIR, svg_filename)

        # Check if we need to regenerate
        should_generate = (
            not os.path.exists(svg_path) or
            processing_cfg.get('force_regenerate', False) or
            not processing_cfg.get('cache', True)
        )

        # Generate SVG if needed
        if should_generate:
            if generate_svg_from_dot(dot_code, svg_path, config):
                diagrams_processed += 1
                print(f"      Generated: /diagrams/{svg_filename}")
            else:
                print(f"Warning: Failed to generate diagram in {source_path}", file=sys.stderr)
                continue
        elif processing_cfg.get('verbose', False):
            print(f"  Using cached diagram: {svg_filename}")

        # Replace the code block with image reference
        replacement = f'![Diagram](/diagrams/{svg_filename})'
        modified_content = (
            modified_content[:match.start()] +
            replacement +
            modified_content[match.end():]
        )

    # Write processed content to destination
    with open(dest_path, 'w', encoding='utf-8') as f:
        f.write(modified_content)

    return diagrams_processed


def find_markdown_files(root_dir):
    """
    Recursively find all markdown files in the given directory.

    Args:
        root_dir: Root directory to search

    Yields:
        Paths to markdown files
    """
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.md'):
                yield os.path.join(root, file)


def copy_directory_structure(src, dst):
    """
    Recursively copy directory structure and files from src to dst.

    Args:
        src: Source directory
        dst: Destination directory
    """
    import shutil
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)


def main():
    """Main entry point for the preprocessor."""
    print("Preprocessing content and generating diagrams...")

    # Load configuration
    config = load_config()
    if config.get('processing', {}).get('verbose', False):
        print(f"  Loaded configuration from {CONFIG_FILE}")

    # Ensure output directories exist
    ensure_dirs()

    # Copy content directory to generated/content
    print(f"  Copying {CONTENT_DIR}/ to {GENERATED_CONTENT_DIR}/...")
    copy_directory_structure(CONTENT_DIR, GENERATED_CONTENT_DIR)

    total_files = 0
    total_diagrams = 0

    # Process all markdown files in generated/content
    print("  Scanning for Graphviz diagrams...")
    for source_file in find_markdown_files(CONTENT_DIR):
        # Calculate relative path and destination
        rel_path = os.path.relpath(source_file, CONTENT_DIR)
        dest_file = os.path.join(GENERATED_CONTENT_DIR, rel_path)

        # Ensure destination directory exists
        os.makedirs(os.path.dirname(dest_file), exist_ok=True)

        # Process the file
        diagrams = process_markdown_file(source_file, dest_file, config)
        if diagrams > 0:
            total_files += 1
            total_diagrams += diagrams
            print(f"  [OK] {rel_path}: {diagrams} diagram(s)")

    print(f"\nProcessed {total_diagrams} diagram(s) in {total_files} file(s)")
    print(f"Generated content ready at: {GENERATED_CONTENT_DIR}/")

    if total_diagrams == 0:
        print("   No diagrams found. Use ```dot code blocks to add Graphviz diagrams.")


if __name__ == '__main__':
    main()
