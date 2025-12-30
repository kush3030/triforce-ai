#!/bin/bash

# ============================================================================
# Agent Chain Orchestrator - Installation Script
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${PURPLE}============================================================================${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}============================================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_header "Agent Chain Orchestrator - Setup"

echo "This script will help you set up the Agent Chain Orchestrator."
echo "It chains together Codex, Gemini, and Claude to build full-stack apps."
echo ""

# ============================================================================
# Step 1: Check Prerequisites
# ============================================================================

print_header "Step 1: Checking Prerequisites"

# Check Node.js
print_step "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js installed: $NODE_VERSION"
else
    print_error "Node.js not found!"
    echo ""
    echo "Please install Node.js first:"
    echo "  - macOS: brew install node"
    echo "  - Or download from: https://nodejs.org/"
    exit 1
fi

# Check npm
print_step "Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm installed: $NPM_VERSION"
else
    print_error "npm not found!"
    exit 1
fi

# ============================================================================
# Step 2: Check AI CLIs
# ============================================================================

print_header "Step 2: Checking AI CLI Tools"

MISSING_TOOLS=()

# Check Codex
print_step "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    print_success "Codex CLI installed: $(which codex)"
else
    print_warning "Codex CLI not found"
    MISSING_TOOLS+=("codex")
fi

# Check Gemini
print_step "Checking Gemini CLI..."
if command -v gemini &> /dev/null; then
    print_success "Gemini CLI installed: $(which gemini)"
else
    print_warning "Gemini CLI not found"
    MISSING_TOOLS+=("gemini")
fi

# Check Claude
print_step "Checking Claude CLI..."
if command -v claude &> /dev/null; then
    print_success "Claude CLI installed: $(which claude)"
else
    print_warning "Claude CLI not found"
    MISSING_TOOLS+=("claude")
fi

# Install missing tools
if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo ""
    print_header "Installing Missing CLI Tools"

    for tool in "${MISSING_TOOLS[@]}"; do
        case $tool in
            codex)
                print_step "Installing Codex CLI..."
                echo "  Run: npm install -g @openai/codex"
                echo ""
                echo "  After installation, authenticate with:"
                echo "    codex login"
                echo ""
                ;;
            gemini)
                print_step "Installing Gemini CLI..."
                echo "  Run: npm install -g @anthropic-ai/gemini"
                echo "  Or check: https://github.com/anthropics/gemini-cli"
                echo ""
                ;;
            claude)
                print_step "Installing Claude CLI (Claude Code)..."
                echo "  Run: npm install -g @anthropic-ai/claude-code"
                echo ""
                echo "  After installation, authenticate with:"
                echo "    claude login"
                echo ""
                ;;
        esac
    done

    echo -e "${YELLOW}Please install the missing tools above, then run this script again.${NC}"
    echo ""
    read -p "Would you like to continue anyway? (y/n): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ============================================================================
# Step 3: Setup GUI (Optional)
# ============================================================================

print_header "Step 3: Setup GUI (Optional)"

echo "The Agent Chain can run in two modes:"
echo ""
echo "  1. CLI Mode (Terminal)"
echo "     Run: ./agent_chain.sh \"Your project description\""
echo ""
echo "  2. GUI Mode (Web Browser)"
echo "     A visual interface with real-time output"
echo ""

read -p "Would you like to set up the Web GUI? (y/n): " setup_gui

if [[ "$setup_gui" =~ ^[Yy]$ ]]; then
    print_step "Setting up GUI..."

    if [ -d "gui" ]; then
        cd gui

        print_step "Installing server dependencies..."
        npm install

        print_step "Installing client dependencies..."
        cd client
        npm install

        print_step "Building React client..."
        npm run build

        cd ../..

        print_success "GUI setup complete!"
    else
        print_error "GUI directory not found. Skipping GUI setup."
    fi
fi

# ============================================================================
# Step 4: Verify Setup
# ============================================================================

print_header "Step 4: Verifying Setup"

# Make script executable
chmod +x agent_chain.sh 2>/dev/null || true

print_step "Checking agent_chain.sh..."
if [ -f "agent_chain.sh" ]; then
    print_success "agent_chain.sh found and executable"
else
    print_error "agent_chain.sh not found!"
    exit 1
fi

# ============================================================================
# Complete
# ============================================================================

print_header "Setup Complete!"

echo "You're all set! Here's how to use Agent Chain:"
echo ""
echo -e "${GREEN}CLI Mode:${NC}"
echo "  ./agent_chain.sh \"Build a todo app with React and Node.js\""
echo ""

if [[ "$setup_gui" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}GUI Mode:${NC}"
    echo "  cd gui && npm start"
    echo "  Then open: http://localhost:3456"
    echo ""
fi

echo -e "${GREEN}The Chain:${NC}"
echo "  1. Codex  → Plans architecture (interactive Q&A)"
echo "  2. Gemini → Builds frontend (auto)"
echo "  3. Claude → Builds backend + wires up frontend (auto)"
echo "  4. Codex  → Reviews & fixes bugs (auto)"
echo ""
echo -e "${YELLOW}Prerequisites:${NC}"
echo "  - codex login  (if not authenticated)"
echo "  - claude login (if not authenticated)"
echo "  - Gemini should work with Google OAuth"
echo ""
echo "Happy building!"
