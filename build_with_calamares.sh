#!/bin/bash
# Arvora OS Build Script with Calamares Integration
# This script builds Arvora OS with Calamares installer

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALAMARES_OUTPUT_DIR="${SCRIPT_DIR}/out/calamares"

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

# Help function
show_help() {
    echo "Arvora OS Build Script with Calamares Integration"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -t, --test     Build with testing enabled"
    echo "  -o, --output   Specify custom output directory (default: out/calamares)"
    echo ""
    echo "This script builds Arvora OS with Calamares installer integration."
    echo "The generated ISO will be placed in the 'out/calamares' directory."
}

# Parse command line arguments
OUTPUT_DIR="$CALAMARES_OUTPUT_DIR"
TEST_FLAG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--test)
            TEST_FLAG=true
            shift
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if we're in the right directory
if [[ ! -f "profiledef.sh" ]]; then
    print_error "This script must be run from the Arvora OS root directory"
    exit 1
fi

# Check if Calamares setup script exists
if [[ ! -f "scripts/setup-calamares.sh" ]]; then
    print_error "Calamares setup script not found. Please run setup-calamares.sh first."
    exit 1
fi

print_status "Building Arvora OS with Calamares integration..."
print_status "Output directory: $OUTPUT_DIR"

# Create output directory and ensure it exists
mkdir -p "$OUTPUT_DIR"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    print_error "Failed to create output directory: $OUTPUT_DIR"
    exit 1
fi
print_success "Output directory created: $OUTPUT_DIR"

# Step 1: Setup Calamares
print_status "Step 1: Setting up Calamares integration..."
./scripts/setup-calamares.sh

# Step 2: Build Arvora OS with custom output directory
print_status "Step 2: Building Arvora OS..."
if [[ "$TEST_FLAG" == true ]]; then
    print_status "Building with testing enabled..."
    OUTPUT_DIR="$OUTPUT_DIR" ./build.sh -c -t
else
    print_status "Building without testing..."
    OUTPUT_DIR="$OUTPUT_DIR" ./build.sh -c
fi

# Step 3: Check if build was successful
if [[ -f "$OUTPUT_DIR/arvora-os-*.iso" ]]; then
    print_success "Arvora OS build completed successfully!"
    
    # List the generated ISO files
    print_status "Generated ISO files:"
    ls -la "$OUTPUT_DIR"/arvora-os-*.iso
    
    print_status "Next steps:"
    print_status "1. Test the ISO with QEMU:"
    print_status "   qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom $OUTPUT_DIR/arvora-os-*.iso"
    print_status "2. Calamares will start automatically on first boot"
    print_status "3. Follow the installation wizard to install Arvora OS"
    
else
    print_error "Build failed! No ISO files found in $OUTPUT_DIR directory."
    exit 1
fi

print_success "Build process completed!" 