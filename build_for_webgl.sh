#!/bin/bash

# Crazy Excavator WebGL Build Script
# This script builds your Godot game for WebGL deployment

# Configuration
PROJECT_NAME="crazy-excavator"
PROJECT_PATH="/Users/danielcraig/crazy-excavator"
BUILD_DIR="builds"
WEBGL_DIR="$BUILD_DIR/webgl"
EXPORT_PRESET="Web"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Godot is installed
check_godot() {
    if ! command -v godot &> /dev/null; then
        print_error "Godot is not installed or not in PATH"
        print_status "Please install Godot 4.x and make sure it's accessible via 'godot' command"
        exit 1
    fi
    
    print_success "Godot found: $(godot --version)"
}

# Function to check if project exists
check_project() {
    if [ ! -d "$PROJECT_PATH" ]; then
        print_error "Project directory not found: $PROJECT_PATH"
        exit 1
    fi
    
    if [ ! -f "$PROJECT_PATH/project.godot" ]; then
        print_error "project.godot not found in: $PROJECT_PATH"
        exit 1
    fi
    
    print_success "Project found: $PROJECT_PATH"
}

# Function to create build directory
create_build_dir() {
    print_status "Creating build directory..."
    mkdir -p "$WEBGL_DIR"
    print_success "Build directory created: $WEBGL_DIR"
}

# Function to setup export preset if it doesn't exist
setup_export_preset() {
    EXPORT_PRESETS_FILE="$PROJECT_PATH/export_presets.cfg"
    
    if [ ! -f "$EXPORT_PRESETS_FILE" ]; then
        print_warning "export_presets.cfg not found, creating one..."
        
        cat > "$EXPORT_PRESETS_FILE" << EOF
[preset.0]

name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="$WEBGL_DIR/index.html"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0, 0, 0, 1)
EOF
        
        print_success "Export preset created"
    else
        print_success "Export preset already exists"
    fi
}

# Function to build the game
build_game() {
    print_status "Starting WebGL build..."
    
    cd "$PROJECT_PATH"
    
    # Export the game
    if godot --headless --export-release "Web" "$WEBGL_DIR/index.html"; then
        print_success "WebGL build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to create a simple local server script
create_server_script() {
    SERVER_SCRIPT="$WEBGL_DIR/serve.py"
    
    cat > "$SERVER_SCRIPT" << 'EOF'
#!/usr/bin/env python3
"""
Simple HTTP server for testing WebGL builds locally.
Godot WebGL builds require proper CORS headers to work correctly.
"""

import http.server
import socketserver
import os
import sys
from urllib.parse import urlparse

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

def serve(port=8000):
    with socketserver.TCPServer(("", port), CORSHTTPRequestHandler) as httpd:
        print(f"Serving at http://localhost:{port}")
        print("Press Ctrl+C to stop the server")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    serve(port)
EOF
    
    chmod +x "$SERVER_SCRIPT"
    print_success "Local server script created: $SERVER_SCRIPT"
}

# Function to create deployment readme
create_deployment_readme() {
    README_FILE="$WEBGL_DIR/README.md"
    
    cat > "$README_FILE" << 'EOF'
# Crazy Excavator - WebGL Build

This directory contains the WebGL build of your Crazy Excavator game.

## Testing Locally

To test the game locally, you need to serve it through a web server due to CORS restrictions:

### Option 1: Using Python (Recommended)
```bash
python3 serve.py
```
Then open http://localhost:8000 in your browser.

### Option 2: Using Node.js
If you have Node.js installed:
```bash
npx serve .
```

### Option 3: Using Python's built-in server
```bash
python3 -m http.server 8000
```

## Deployment

You can deploy these files to any web hosting service:

### Popular Options:
- **GitHub Pages**: Upload to a GitHub repository and enable Pages
- **Netlify**: Drag and drop the entire webgl folder
- **Vercel**: Deploy via Git or drag and drop
- **itch.io**: Upload as a zip file for HTML5 games

### Files in this build:
- `index.html` - Main game file
- `index.js` - Game JavaScript
- `index.wasm` - WebAssembly binary
- `index.pck` - Game resources
- `index.png` - Game icon
- `serve.py` - Local testing server

## Notes

- The game requires a modern web browser with WebGL support
- Some browsers may require HTTPS for certain features
- Mobile support depends on the original game's input handling
EOF
    
    print_success "Deployment README created: $README_FILE"
}

# Function to show build summary
show_summary() {
    echo ""
    echo "=================================="
    echo "    BUILD SUMMARY"
    echo "=================================="
    echo "Project: $PROJECT_NAME"
    echo "Build Location: $WEBGL_DIR"
    echo "Files created:"
    ls -la "$WEBGL_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Test locally: cd $WEBGL_DIR && python3 serve.py"
    echo "2. Open http://localhost:8000 in your browser"
    echo "3. Deploy to your preferred web hosting service"
    echo ""
    print_success "Build process completed!"
}

# Main execution
main() {
    print_status "Starting Crazy Excavator WebGL build process..."
    
    check_godot
    check_project
    create_build_dir
    setup_export_preset
    build_game
    create_server_script
    create_deployment_readme
    show_summary
}

# Run the main function
main "$@"