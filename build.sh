#!/usr/bin/env bash
# Arvora OS Build Script
# Automated ISO building with optimization and testing

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/work"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRIPT_DIR}/output}"
PROFILE_NAME="arvora-os"
ARCHISO_DIR="/usr/share/archiso/configs/releng"

# Debug output for OUTPUT_DIR
if [[ -n "${OUTPUT_DIR:-}" ]]; then
    echo -e "${BLUE}[DEBUG]${NC} Using custom OUTPUT_DIR: $OUTPUT_DIR"
fi

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

# Warning function
warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Success function
success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

# Check dependencies
check_dependencies() {
    log "Checking build dependencies..."
    
    local missing_deps=()
    
    # Check for required packages
    local required_packages=(
        "archiso"
        "squashfs-tools"
        "dosfstools"
        "libisoburn"
        "mtools"
        "cdrkit"
        "syslinux"
    )
    
    for package in "${required_packages[@]}"; do
        if ! pacman -Q "$package" >/dev/null 2>&1; then
            missing_deps+=("$package")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing_deps[*]}"
        echo "Install them with: sudo pacman -S ${missing_deps[*]}"
    fi
    
    # Check for archiso
    if [[ ! -d "$ARCHISO_DIR" ]]; then
        error "archiso not found at $ARCHISO_DIR"
        echo "Install archiso: sudo pacman -S archiso"
    fi
    
    success "All dependencies satisfied"
}

# Clean previous builds
clean_build() {
    log "Cleaning previous build artifacts..."
    
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
        log "Removed previous build directory"
    fi
    
    if [[ -d "$OUTPUT_DIR" ]]; then
        rm -rf "$OUTPUT_DIR"
        log "Removed previous output directory"
    fi
    
    # Clean any leftover files
    find . -name "*.iso" -type f -delete 2>/dev/null || true
    find . -name "*.md5" -type f -delete 2>/dev/null || true
    find . -name "*.sha256" -type f -delete 2>/dev/null || true
    
    success "Build environment cleaned"
}

# Prepare build environment
prepare_build() {
    log "Preparing build environment..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Copy archiso profile
    if [[ ! -d "$BUILD_DIR" ]]; then
        cp -r "$ARCHISO_DIR" "$BUILD_DIR"
        log "Copied archiso profile to build directory"
    fi
    
    # Copy our custom files
    cp "$SCRIPT_DIR/profiledef.sh" "$BUILD_DIR/"
    cp "$SCRIPT_DIR/packages.x86_64" "$BUILD_DIR/"
    cp "$SCRIPT_DIR/pacman.conf" "$BUILD_DIR/"
    
    # Copy custom scripts to airootfs
    mkdir -p "$BUILD_DIR/airootfs/usr/local/bin"
    cp "$SCRIPT_DIR/airootfs/usr/local/bin/arvora-test" "$BUILD_DIR/airootfs/usr/local/bin/"
    cp "$SCRIPT_DIR/airootfs/usr/local/bin/arvora-diagnostics" "$BUILD_DIR/airootfs/usr/local/bin/"
    
    # Make scripts executable
    chmod +x "$BUILD_DIR/airootfs/usr/local/bin/arvora-test"
    chmod +x "$BUILD_DIR/airootfs/usr/local/bin/arvora-diagnostics"
    
    success "Build environment prepared"
}

# Build the ISO
build_iso() {
    log "Starting ISO build process..."
    log "Output directory: $OUTPUT_DIR"
    
    cd "$BUILD_DIR"
    
    # Set environment variables for reproducible builds
    export SOURCE_DATE_EPOCH=$(date +%s)
    
    # Build the ISO
    log "Running mkarchiso..."
    if mkarchiso -v -w "$BUILD_DIR" -o "$OUTPUT_DIR" .; then
        success "ISO build completed successfully"
    else
        error "ISO build failed"
    fi
}

# Generate checksums
generate_checksums() {
    log "Generating checksums..."
    
    cd "$OUTPUT_DIR"
    
    for iso_file in *.iso; do
        if [[ -f "$iso_file" ]]; then
            log "Generating checksums for $iso_file"
            md5sum "$iso_file" > "$iso_file.md5"
            sha256sum "$iso_file" > "$iso_file.sha256"
        fi
    done
    
    success "Checksums generated"
}

# Test the ISO
test_iso() {
    log "Testing ISO integrity..."
    
    cd "$OUTPUT_DIR"
    
    for iso_file in *.iso; do
        if [[ -f "$iso_file" ]]; then
            log "Testing $iso_file"
            
            # Check if ISO is valid
            if file "$iso_file" | grep -q "ISO 9660"; then
                success "ISO format validation passed for $iso_file"
            else
                warning "ISO format validation failed for $iso_file"
            fi
            
            # Check file size
            local size=$(du -h "$iso_file" | cut -f1)
            log "ISO size: $size"
        fi
    done
}

# Show build information
show_build_info() {
    log "Build completed successfully!"
    echo ""
    echo -e "${CYAN}=== Build Information ===${NC}"
    echo "Build directory: $BUILD_DIR"
    echo "Output directory: $OUTPUT_DIR"
    echo "Build date: $(date)"
    echo ""
    
    if [[ -d "$OUTPUT_DIR" ]]; then
        echo -e "${CYAN}Generated files:${NC}"
        ls -lh "$OUTPUT_DIR"
        echo ""
        
        echo -e "${CYAN}Checksums:${NC}"
        for checksum_file in "$OUTPUT_DIR"/*.md5 "$OUTPUT_DIR"/*.sha256; do
            if [[ -f "$checksum_file" ]]; then
                cat "$checksum_file"
            fi
        done
    fi
}

# Help function
show_help() {
    echo "Arvora OS Build Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --clean    Clean build environment before building"
    echo "  -t, --test     Run tests after building"
    echo "  -v, --verbose  Enable verbose output"
    echo "  --skip-deps    Skip dependency checking"
    echo ""
    echo "This script builds the Arvora OS ISO with the following steps:"
    echo "  1. Check dependencies"
    echo "  2. Clean previous builds (if -c specified)"
    echo "  3. Prepare build environment"
    echo "  4. Build the ISO"
    echo "  5. Generate checksums"
    echo "  6. Test the ISO (if -t specified)"
    echo ""
    echo "The generated ISO will be placed in the 'output' directory."
}

# Main function
main() {
    local clean_build_flag=false
    local test_flag=false
    local verbose_flag=false
    local skip_deps_flag=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--clean)
                clean_build_flag=true
                shift
                ;;
            -t|--test)
                test_flag=true
                shift
                ;;
            -v|--verbose)
                verbose_flag=true
                shift
                ;;
            --skip-deps)
                skip_deps_flag=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
    
    # Enable verbose mode if requested
    if [[ "$verbose_flag" == true ]]; then
        set -x
    fi
    
    echo -e "${GREEN}=== Arvora OS Build Script ===${NC}"
    echo "Starting build process..."
    echo ""
    
    # Check dependencies
    if [[ "$skip_deps_flag" == false ]]; then
        check_dependencies
    fi
    
    # Clean build if requested
    if [[ "$clean_build_flag" == true ]]; then
        clean_build
    fi
    
    # Prepare build environment
    prepare_build
    
    # Build the ISO
    build_iso
    
    # Generate checksums
    generate_checksums
    
    # Test the ISO if requested
    if [[ "$test_flag" == true ]]; then
        test_iso
    fi
    
    # Show build information
    show_build_info
}

# Run main function
main "$@" 