#!/usr/bin/env bash
# Arvora OS Test Runner
# Automated testing script for CI/CD environments

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/work"
OUTPUT_DIR="${SCRIPT_DIR}/output"
TEST_RESULTS_FILE="${SCRIPT_DIR}/test-results.json"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

# Success function
success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Initialize test results
init_test_results() {
    cat > "$TEST_RESULTS_FILE" << EOF
{
    "test_run": {
        "timestamp": "$(date -Iseconds)",
        "version": "1.0",
        "environment": {
            "os": "$(uname -s)",
            "arch": "$(uname -m)",
            "kernel": "$(uname -r)"
        },
        "tests": []
    }
}
EOF
}

# Add test result
add_test_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    local duration="$4"
    
    # Create temporary file with new test result
    local temp_file=$(mktemp)
    
    # Add test result to JSON
    jq --arg name "$test_name" \
       --arg status "$status" \
       --arg message "$message" \
       --arg duration "$duration" \
       '.test_run.tests += [{"name": $name, "status": $status, "message": $message, "duration": $duration}]' \
       "$TEST_RESULTS_FILE" > "$temp_file"
    
    mv "$temp_file" "$TEST_RESULTS_FILE"
}

# Test build process
test_build() {
    log "Testing build process..."
    local start_time=$(date +%s)
    
    if ./build.sh -c -t; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        add_test_result "build" "PASS" "ISO build completed successfully" "$duration"
        success "Build test passed"
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        add_test_result "build" "FAIL" "ISO build failed" "$duration"
        error "Build test failed"
    fi
}

# Test ISO integrity
test_iso_integrity() {
    log "Testing ISO integrity..."
    local start_time=$(date +%s)
    
    cd "$OUTPUT_DIR"
    
    for iso_file in *.iso; do
        if [[ -f "$iso_file" ]]; then
            # Check if ISO is valid
            if file "$iso_file" | grep -q "ISO 9660"; then
                # Verify checksums
                if md5sum -c "$iso_file.md5" && sha256sum -c "$iso_file.sha256"; then
                    local end_time=$(date +%s)
                    local duration=$((end_time - start_time))
                    add_test_result "iso_integrity" "PASS" "ISO integrity verified for $iso_file" "$duration"
                    success "ISO integrity test passed"
                    return 0
                else
                    local end_time=$(date +%s)
                    local duration=$((end_time - start_time))
                    add_test_result "iso_integrity" "FAIL" "ISO checksum verification failed for $iso_file" "$duration"
                    error "ISO integrity test failed"
                fi
            else
                local end_time=$(date +%s)
                local duration=$((end_time - start_time))
                add_test_result "iso_integrity" "FAIL" "Invalid ISO format for $iso_file" "$duration"
                error "ISO integrity test failed"
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    add_test_result "iso_integrity" "FAIL" "No ISO files found" "$duration"
    error "No ISO files found for integrity testing"
}

# Test ISO boot (if QEMU is available)
test_iso_boot() {
    log "Testing ISO boot process..."
    local start_time=$(date +%s)
    
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        add_test_result "iso_boot" "SKIP" "QEMU not available for boot testing" "$duration"
        warning "QEMU not available, skipping boot test"
        return 0
    fi
    
    cd "$OUTPUT_DIR"
    
    for iso_file in *.iso; do
        if [[ -f "$iso_file" ]]; then
            # Start QEMU in background with timeout
            timeout 60s qemu-system-x86_64 \
                -enable-kvm \
                -m 1G \
                -smp 2 \
                -boot d \
                -cdrom "$iso_file" \
                -nographic \
                -serial mon:stdio \
                -no-reboot \
                -no-shutdown > /tmp/qemu-boot-test.log 2>&1 &
            
            local qemu_pid=$!
            local boot_success=false
            
            # Wait for boot indicators
            for i in {1..30}; do
                if grep -q "login:" /tmp/qemu-boot-test.log 2>/dev/null; then
                    boot_success=true
                    break
                fi
                sleep 2
            done
            
            # Kill QEMU
            kill $qemu_pid 2>/dev/null || true
            wait $qemu_pid 2>/dev/null || true
            
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            if [[ "$boot_success" == true ]]; then
                add_test_result "iso_boot" "PASS" "ISO boot test passed for $iso_file" "$duration"
                success "ISO boot test passed"
            else
                add_test_result "iso_boot" "FAIL" "ISO boot test failed for $iso_file" "$duration"
                warning "ISO boot test failed (this may be expected in CI environment)"
            fi
            
            return 0
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    add_test_result "iso_boot" "FAIL" "No ISO files found for boot testing" "$duration"
    error "No ISO files found for boot testing"
}

# Test file structure
test_file_structure() {
    log "Testing file structure..."
    local start_time=$(date +%s)
    
    local required_files=(
        "profiledef.sh"
        "packages.x86_64"
        "pacman.conf"
        "build.sh"
        "airootfs/usr/local/bin/arvora-test"
        "airootfs/usr/local/bin/arvora-diagnostics"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        add_test_result "file_structure" "PASS" "All required files present" "$duration"
        success "File structure test passed"
    else
        add_test_result "file_structure" "FAIL" "Missing files: ${missing_files[*]}" "$duration"
        error "File structure test failed: missing ${missing_files[*]}"
    fi
}

# Test script permissions
test_script_permissions() {
    log "Testing script permissions..."
    local start_time=$(date +%s)
    
    local scripts=(
        "build.sh"
        "airootfs/usr/local/bin/arvora-test"
        "airootfs/usr/local/bin/arvora-diagnostics"
    )
    
    local invalid_permissions=()
    
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            if [[ ! -x "$SCRIPT_DIR/$script" ]]; then
                invalid_permissions+=("$script")
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ ${#invalid_permissions[@]} -eq 0 ]]; then
        add_test_result "script_permissions" "PASS" "All scripts have executable permissions" "$duration"
        success "Script permissions test passed"
    else
        add_test_result "script_permissions" "FAIL" "Scripts without executable permissions: ${invalid_permissions[*]}" "$duration"
        error "Script permissions test failed: ${invalid_permissions[*]}"
    fi
}

# Generate test summary
generate_summary() {
    log "Generating test summary..."
    
    local total_tests=$(jq '.test_run.tests | length' "$TEST_RESULTS_FILE")
    local passed_tests=$(jq '.test_run.tests | map(select(.status == "PASS")) | length' "$TEST_RESULTS_FILE")
    local failed_tests=$(jq '.test_run.tests | map(select(.status == "FAIL")) | length' "$TEST_RESULTS_FILE")
    local skipped_tests=$(jq '.test_run.tests | map(select(.status == "SKIP")) | length' "$TEST_RESULTS_FILE")
    
    # Add summary to JSON
    local temp_file=$(mktemp)
    jq --arg total "$total_tests" \
       --arg passed "$passed_tests" \
       --arg failed "$failed_tests" \
       --arg skipped "$skipped_tests" \
       '.test_run.summary = {"total": $total, "passed": $passed, "failed": $failed, "skipped": $skipped}' \
       "$TEST_RESULTS_FILE" > "$temp_file"
    
    mv "$temp_file" "$TEST_RESULTS_FILE"
    
    echo ""
    echo "=== Test Summary ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $failed_tests"
    echo "Skipped: $skipped_tests"
    echo ""
    
    if [[ $failed_tests -eq 0 ]]; then
        success "All tests passed!"
        echo "Test results saved to: $TEST_RESULTS_FILE"
        exit 0
    else
        error "Some tests failed. Check $TEST_RESULTS_FILE for details."
        exit 1
    fi
}

# Help function
show_help() {
    echo "Arvora OS Test Runner"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo "  --skip-build   Skip build testing"
    echo "  --skip-boot    Skip boot testing"
    echo ""
    echo "This script runs automated tests for Arvora OS including:"
    echo "  - Build process testing"
    echo "  - ISO integrity verification"
    echo "  - ISO boot testing (if QEMU available)"
    echo "  - File structure validation"
    echo "  - Script permissions checking"
    echo ""
    echo "Test results are saved to test-results.json"
}

# Main function
main() {
    local verbose_flag=false
    local skip_build_flag=false
    local skip_boot_flag=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose_flag=true
                shift
                ;;
            --skip-build)
                skip_build_flag=true
                shift
                ;;
            --skip-boot)
                skip_boot_flag=true
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
    
    echo -e "${GREEN}=== Arvora OS Test Runner ===${NC}"
    echo "Starting automated testing..."
    echo ""
    
    # Initialize test results
    init_test_results
    
    # Run tests
    test_file_structure
    test_script_permissions
    
    if [[ "$skip_build_flag" == false ]]; then
        test_build
        test_iso_integrity
    else
        log "Skipping build tests as requested"
    fi
    
    if [[ "$skip_boot_flag" == false ]]; then
        test_iso_boot
    else
        log "Skipping boot tests as requested"
    fi
    
    # Generate summary
    generate_summary
}

# Run main function
main "$@" 