#!/bin/bash

# DXB Events Web App Test Runner Script
# Usage: ./scripts/test.sh [test_type] [options]
# Test Types: unit, widget, integration, performance, all
# Options: --coverage, --verbose, --no-sound-null-safety

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE=${1:-all}
COVERAGE=false
VERBOSE=false
SOUND_NULL_SAFETY=true
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Parse command line arguments
for arg in "$@"
do
    case $arg in
        --coverage)
        COVERAGE=true
        shift
        ;;
        --verbose)
        VERBOSE=true
        shift
        ;;
        --no-sound-null-safety)
        SOUND_NULL_SAFETY=false
        shift
        ;;
    esac
done

echo -e "${BLUE}🧪 DXB Events Web App Test Runner${NC}"
echo -e "${BLUE}Test Type: ${YELLOW}$TEST_TYPE${NC}"
echo -e "${BLUE}Coverage: ${YELLOW}$COVERAGE${NC}"
echo -e "${BLUE}Verbose: ${YELLOW}$VERBOSE${NC}"
echo -e "${BLUE}Sound Null Safety: ${YELLOW}$SOUND_NULL_SAFETY${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to log messages
log_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check prerequisites
log_info "Checking prerequisites..."

if ! command_exists flutter; then
    log_error "Flutter is not installed or not in PATH"
    exit 1
fi

if ! command_exists dart; then
    log_error "Dart is not installed or not in PATH"
    exit 1
fi

# Navigate to project directory
cd "$ROOT_DIR"

# Get dependencies
log_info "Getting Flutter dependencies..."
flutter pub get

# Set test arguments
TEST_ARGS=()

if [ "$COVERAGE" = true ]; then
    TEST_ARGS+=("--coverage")
fi

if [ "$VERBOSE" = true ]; then
    TEST_ARGS+=("--verbose")
fi

if [ "$SOUND_NULL_SAFETY" = false ]; then
    TEST_ARGS+=("--no-sound-null-safety")
fi

# Function to run unit tests
run_unit_tests() {
    log_info "Running unit tests..."
    
    if [ -d "test/" ]; then
        # Find unit test files (excluding widget, integration, and performance tests)
        UNIT_TEST_FILES=$(find test/ -name "*_test.dart" \
            ! -path "test/widgets/*" \
            ! -path "test/integration/*" \
            ! -path "test/performance/*" \
            ! -path "test/e2e/*")
        
        if [ -n "$UNIT_TEST_FILES" ]; then
            echo -e "${PURPLE}📝 Unit test files found:${NC}"
            echo "$UNIT_TEST_FILES"
            
            flutter test $UNIT_TEST_FILES "${TEST_ARGS[@]}"
            log_success "Unit tests completed"
        else
            log_warning "No unit test files found"
        fi
    else
        log_warning "No test directory found"
    fi
}

# Function to run widget tests
run_widget_tests() {
    log_info "Running widget tests..."
    
    if [ -d "test/widgets/" ]; then
        WIDGET_TEST_FILES=$(find test/widgets/ -name "*_test.dart")
        
        if [ -n "$WIDGET_TEST_FILES" ]; then
            echo -e "${PURPLE}🎨 Widget test files found:${NC}"
            echo "$WIDGET_TEST_FILES"
            
            flutter test test/widgets/ "${TEST_ARGS[@]}"
            log_success "Widget tests completed"
        else
            log_warning "No widget test files found"
        fi
    else
        log_warning "No widget test directory found"
    fi
}

# Function to run integration tests
run_integration_tests() {
    log_info "Running integration tests..."
    
    if [ -d "test/integration/" ]; then
        # Check if integration_test package is available
        if ! flutter packages pub deps | grep -q "integration_test"; then
            log_warning "integration_test package not found in dependencies"
            log_info "Add 'integration_test:' to dev_dependencies in pubspec.yaml"
            return
        fi
        
        INTEGRATION_TEST_FILES=$(find test/integration/ -name "*_test.dart")
        
        if [ -n "$INTEGRATION_TEST_FILES" ]; then
            echo -e "${PURPLE}🔗 Integration test files found:${NC}"
            echo "$INTEGRATION_TEST_FILES"
            
            # Integration tests require a special command
            flutter test integration_test/ "${TEST_ARGS[@]}" || \
            flutter test test/integration/ "${TEST_ARGS[@]}"
            log_success "Integration tests completed"
        else
            log_warning "No integration test files found"
        fi
    else
        log_warning "No integration test directory found"
    fi
}

# Function to run performance tests
run_performance_tests() {
    log_info "Running performance tests..."
    
    if [ -d "test/performance/" ]; then
        PERFORMANCE_TEST_FILES=$(find test/performance/ -name "*_test.dart")
        
        if [ -n "$PERFORMANCE_TEST_FILES" ]; then
            echo -e "${PURPLE}⚡ Performance test files found:${NC}"
            echo "$PERFORMANCE_TEST_FILES"
            
            # Performance tests with timeline recording
            flutter test test/performance/ "${TEST_ARGS[@]}" --reporter=compact
            log_success "Performance tests completed"
        else
            log_warning "No performance test files found"
        fi
    else
        log_warning "No performance test directory found"
    fi
}

# Function to generate test coverage report
generate_coverage_report() {
    if [ "$COVERAGE" = true ]; then
        log_info "Generating coverage report..."
        
        if [ -f "coverage/lcov.info" ]; then
            # Install genhtml if available for HTML coverage reports
            if command_exists genhtml; then
                log_info "Generating HTML coverage report..."
                genhtml coverage/lcov.info -o coverage/html
                log_success "HTML coverage report generated at coverage/html/index.html"
            fi
            
            # Install lcov_cobertura if available for Cobertura format
            if command_exists lcov_cobertura; then
                log_info "Generating Cobertura coverage report..."
                lcov_cobertura coverage/lcov.info --output coverage/coverage.xml
                log_success "Cobertura coverage report generated at coverage/coverage.xml"
            fi
            
            # Generate coverage summary
            if command_exists lcov; then
                log_info "Generating coverage summary..."
                lcov --summary coverage/lcov.info > coverage/summary.txt 2>&1
                
                # Extract coverage percentage
                COVERAGE_PERCENT=$(grep -o "lines......: [0-9.]*%" coverage/summary.txt | grep -o "[0-9.]*" || echo "Unknown")
                
                echo -e "${BLUE}📊 Coverage Summary:${NC}"
                cat coverage/summary.txt
                echo -e "${BLUE}Overall Coverage: ${YELLOW}${COVERAGE_PERCENT}%${NC}"
                
                # Check if coverage meets threshold (80%)
                if (( $(echo "$COVERAGE_PERCENT >= 80" | bc -l) 2>/dev/null )); then
                    log_success "Coverage threshold met (≥80%)"
                else
                    log_warning "Coverage below threshold (<80%)"
                fi
            fi
        else
            log_warning "No coverage data found at coverage/lcov.info"
        fi
    fi
}

# Function to run all tests
run_all_tests() {
    log_info "Running all tests..."
    
    echo -e "${BLUE}🚀 Starting comprehensive test suite${NC}"
    
    # Run tests in order
    run_unit_tests
    echo ""
    
    run_widget_tests
    echo ""
    
    run_integration_tests
    echo ""
    
    run_performance_tests
    echo ""
    
    generate_coverage_report
}

# Function to analyze test results
analyze_test_results() {
    log_info "Analyzing test results..."
    
    # Create test report
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    FLUTTER_VERSION=$(flutter --version | head -1)
    
    cat > test_report.txt << EOF
DXB Events Web App Test Report
==============================
Test Date: $TIMESTAMP
Test Type: $TEST_TYPE
Flutter Version: $FLUTTER_VERSION
Coverage Enabled: $COVERAGE

Test Directories:
$(find test/ -type d 2>/dev/null || echo "No test directories found")

Test Files:
$(find test/ -name "*_test.dart" 2>/dev/null | wc -l || echo "0") test files found

$(if [ -f "coverage/summary.txt" ]; then
    echo "Coverage Summary:"
    cat coverage/summary.txt
fi)
EOF
    
    log_success "Test report generated: test_report.txt"
}

# Main execution
case $TEST_TYPE in
    unit)
        run_unit_tests
        ;;
    widget)
        run_widget_tests
        ;;
    integration)
        run_integration_tests
        ;;
    performance)
        run_performance_tests
        ;;
    all)
        run_all_tests
        ;;
    *)
        log_error "Unknown test type: $TEST_TYPE"
        log_info "Available test types: unit, widget, integration, performance, all"
        exit 1
        ;;
esac

# Generate coverage report if requested
if [ "$COVERAGE" = true ] && [ "$TEST_TYPE" != "all" ]; then
    generate_coverage_report
fi

# Analyze results
analyze_test_results

# Display final summary
echo ""
echo -e "${GREEN}🎉 Test execution completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   Test Type: ${YELLOW}$TEST_TYPE${NC}"
echo -e "   Coverage: ${YELLOW}$COVERAGE${NC}"

if [ -f "test_report.txt" ]; then
    echo -e "   Report: ${YELLOW}test_report.txt${NC}"
fi

if [ "$COVERAGE" = true ] && [ -f "coverage/lcov.info" ]; then
    echo -e "   Coverage Data: ${YELLOW}coverage/lcov.info${NC}"
    
    if [ -d "coverage/html" ]; then
        echo -e "   HTML Report: ${YELLOW}coverage/html/index.html${NC}"
    fi
fi

echo ""
echo -e "${BLUE}💡 Next Steps:${NC}"
echo -e "   • Review test results above"
echo -e "   • Check coverage reports (if enabled)"
echo -e "   • Fix any failing tests"
echo -e "   • Add more tests for better coverage"

if [ "$COVERAGE" = true ]; then
    echo ""
    echo -e "${BLUE}🌐 To view HTML coverage report:${NC}"
    echo -e "   open coverage/html/index.html"
fi 