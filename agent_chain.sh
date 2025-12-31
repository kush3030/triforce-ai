#!/bin/bash

# Agent Chain Orchestrator
# Chains Codex -> Gemini -> Claude for full-stack project generation
# Usage: ./agent_chain.sh "Your project description"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

print_header() {
    echo ""
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==================================================${NC}"
}

print_stage() {
    echo ""
    echo -e "${PURPLE}--------------------------------------------------${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}--------------------------------------------------${NC}"
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

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Check if required commands exist
check_dependencies() {
    local missing=()

    if ! command -v codex &> /dev/null; then
        missing+=("codex")
    fi
    if ! command -v gemini &> /dev/null; then
        missing+=("gemini")
    fi
    if ! command -v claude &> /dev/null; then
        missing+=("claude")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing required commands: ${missing[*]}"
        print_error "Please install all required CLI tools before running this script."
        exit 1
    fi
}

# Generate a folder name from the project prompt
generate_folder_name() {
    local prompt="$1"
    echo "$prompt" | tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9 ]//g' | \
        sed 's/  */ /g' | \
        sed 's/ /-/g' | \
        cut -c1-40 | \
        sed 's/-$//'
}

# Confirm before proceeding to next stage
confirm_proceed() {
    local next_stage="$1"
    echo ""
    while true; do
        read -p "Proceed to $next_stage? (y/n): " choice
        case "$choice" in
            y|Y)
                print_success "Proceeding to $next_stage..."
                return 0
                ;;
            n|N)
                print_warning "Chain stopped by user."
                exit 0
                ;;
            *)
                echo "Please enter y or n."
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Main Script
# -----------------------------------------------------------------------------

# Check all tools are installed
check_dependencies

# Get project prompt from command line argument
if [ -z "$1" ]; then
    print_error "Usage: $0 \"Your project description\""
    print_error "Example: $0 \"Build a snake game with HTML, JS, and CSS\""
    exit 1
fi

PROJECT_PROMPT="$1"

# Generate project folder name and create it
PROJECT_FOLDER=$(generate_folder_name "$PROJECT_PROMPT")
PROJECT_PATH="$(pwd)/$PROJECT_FOLDER"

print_header "AI Agent Chain Orchestrator"
echo "Project: $PROJECT_PROMPT"
echo "Folder:  $PROJECT_FOLDER/"
echo ""
echo "Chain: Codex (Planning) -> Gemini (Frontend) -> Claude (Backend) -> Codex (Review)"

# Create project folder if it doesn't exist
if [ ! -d "$PROJECT_PATH" ]; then
    mkdir -p "$PROJECT_PATH"
    print_success "Created project folder: $PROJECT_FOLDER/"
else
    print_warning "Project folder already exists: $PROJECT_FOLDER/"
fi

# Change to project directory - all agents will work here
cd "$PROJECT_PATH"
echo ""
print_success "Working directory: $(pwd)"

# Configuration - paths relative to project folder
PLAN_FILE="implementation_plan.md"
FRONTEND_PLAN="frontend_plan.md"
BACKEND_PLAN="backend_plan.md"
FRONTEND_MARKER="frontend/README.md"
BACKEND_MARKER="backend/README.md"
REVIEW_MARKER=".code_review_done"

# -----------------------------------------------------------------------------
# Stage 1: Codex - Planning & Architecture
# -----------------------------------------------------------------------------

print_stage "[Stage 1/4] Codex: Planning & Architecture"

if [ -f "$PLAN_FILE" ]; then
    print_success "Found existing $PLAN_FILE - skipping Codex stage."
    echo "Delete $PLAN_FILE to regenerate the plan."
else
    echo "Codex will help you create implementation plans."
    echo ""
    echo "Tips:"
    echo "  - Codex will create separate plans for frontend and backend"
    echo "  - You can guide the AI and answer questions"
    echo -e "  - ${YELLOW}When done, press Ctrl+C to exit and move to the next stage${NC}"
    echo ""
    read -p "Press Enter to start Codex..."

    CODEX_PROMPT="You are a Technical Architect helping plan a software project.

PROJECT REQUEST: $PROJECT_PROMPT

WORKING DIRECTORY: $(pwd)

YOUR PROCESS:
1. Ask 2-3 clarifying questions about requirements, tech stack, and constraints
2. Iterate with the user until requirements are clear
3. When ready, create THREE separate plan files:

FILE 1: '$PLAN_FILE' (Main Overview)
- Project overview and goals
- Tech stack decisions
- High-level architecture
- Whether backend is needed (yes/no with reason)

FILE 2: '$FRONTEND_PLAN' (For Frontend Developer)
- Detailed frontend file/folder structure
- Component breakdown with descriptions
- State management approach
- UI/UX requirements
- Step-by-step frontend implementation guide
- If no frontend needed, write 'No frontend required' and explain why

FILE 3: '$BACKEND_PLAN' (For Backend Developer)
- Detailed backend file/folder structure
- API endpoints with request/response formats
- Database schema
- Authentication/authorization approach
- Step-by-step backend implementation guide
- If no backend needed, write 'No backend required - this is a frontend-only application' and explain why

Start by asking 2-3 clarifying questions about the project."

    codex --sandbox=workspace-write --full-auto "$CODEX_PROMPT"

    # Check if plan was created
    if [ ! -f "$PLAN_FILE" ]; then
        print_warning "Warning: $PLAN_FILE was not created."
        read -p "Continue anyway? (y/n): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

print_success "Stage 1 Complete: Planning done."

# Confirm before Stage 2
confirm_proceed "Stage 2 (Gemini Frontend)"

# -----------------------------------------------------------------------------
# Stage 2: Gemini - Frontend Engineering
# -----------------------------------------------------------------------------

print_stage "[Stage 2/4] Gemini: Frontend Engineering"

# Check if frontend plan says "no frontend needed"
if [ -f "$FRONTEND_PLAN" ] && grep -qi "no frontend required" "$FRONTEND_PLAN"; then
    print_success "Frontend plan indicates no frontend needed - skipping Gemini stage."
elif [ -f "$FRONTEND_MARKER" ]; then
    print_success "Found existing $FRONTEND_MARKER - skipping Gemini stage."
    echo "Delete the frontend/ folder to regenerate."
else
    echo "Gemini will build the frontend based on frontend_plan.md"
    echo ""
    echo "Tips:"
    echo "  - Gemini will create a 'frontend/' folder with your code"
    echo "  - You can guide the AI during development"
    echo -e "  - ${YELLOW}When done, press Ctrl+C to exit and move to the next stage${NC}"
    echo ""
    read -p "Press Enter to start Gemini..."

    GEMINI_PROMPT="Read $FRONTEND_PLAN and build the complete frontend in a frontend/ folder. Use any CSS framework or styling approach that fits the project. Create frontend/README.md with setup instructions."

    # Use -i flag for interactive mode with initial prompt, -y for YOLO mode
    gemini -y -i "$GEMINI_PROMPT"

    if [ ! -f "$FRONTEND_MARKER" ]; then
        print_warning "Warning: $FRONTEND_MARKER was not created."
        read -p "Continue anyway? (y/n): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

print_success "Stage 2 Complete: Frontend done."

# Confirm before Stage 3
confirm_proceed "Stage 3 (Claude Backend)"

# -----------------------------------------------------------------------------
# Stage 3: Claude - Backend Engineering
# -----------------------------------------------------------------------------

print_stage "[Stage 3/4] Claude: Backend Engineering"

# Check if backend plan says "no backend needed"
if [ -f "$BACKEND_PLAN" ] && grep -qi "no backend required" "$BACKEND_PLAN"; then
    print_success "Backend plan indicates no backend needed - skipping Claude stage."
    # Create marker so we don't get warning
    mkdir -p backend
    echo "# No Backend Required" > "$BACKEND_MARKER"
    echo "" >> "$BACKEND_MARKER"
    echo "This is a frontend-only application. No backend server is needed." >> "$BACKEND_MARKER"
elif [ -f "$BACKEND_MARKER" ]; then
    print_success "Found existing $BACKEND_MARKER - skipping Claude stage."
    echo "Delete the backend/ folder to regenerate."
else
    echo "Claude will build the backend based on backend_plan.md"
    echo ""
    echo "Tips:"
    echo "  - Claude will create a 'backend/' folder with your code"
    echo "  - You can guide the AI during development"
    echo -e "  - ${YELLOW}When done, press Ctrl+C to exit and move to the next stage${NC}"
    echo ""
    read -p "Press Enter to start Claude..."

    CLAUDE_PROMPT="You are a Senior Fullstack Engineer.

WORKING DIRECTORY: $(pwd)

STEP 1: Read '$BACKEND_PLAN' to understand what backend to build.

IF THE PLAN SAYS 'No backend required':
- Create 'backend/README.md' saying 'No backend required for this project.'
- Say 'No backend needed. User can press Ctrl+C to continue.'
- Done.

IF BACKEND IS NEEDED:
STEP 2: Create a 'backend/' directory and build the complete backend:
- Follow the file structure in the plan
- Implement ALL API endpoints specified
- Set up database/storage as specified
- Add proper CORS configuration (allow frontend origin)
- Include authentication if specified
- Add error handling and input validation

STEP 3: Create 'backend/README.md' with:
- Project description
- Setup instructions (npm install, environment variables)
- How to run (npm start, port number)
- API endpoint documentation

STEP 4: Wire up the frontend:
- Go to 'frontend/' folder
- Find all TODO comments about API calls
- Replace mock data with real fetch/axios calls to backend
- Use proper error handling for API responses

STEP 5: After completing everything, say 'Backend complete. User can press Ctrl+C to continue.'

Build everything now. No questions, just code."

    claude --dangerously-skip-permissions "$CLAUDE_PROMPT"

    if [ ! -f "$BACKEND_MARKER" ]; then
        print_warning "Warning: $BACKEND_MARKER was not created."
    fi
fi

print_success "Stage 3 Complete: Backend done."

# Confirm before Stage 4
confirm_proceed "Stage 4 (Codex Code Review)"

# -----------------------------------------------------------------------------
# Stage 4: Codex - Senior Fullstack Review & Bug Fixing
# -----------------------------------------------------------------------------

print_stage "[Stage 4/4] Codex: Fullstack Code Review & Bug Fixing"

if [ -f "$REVIEW_MARKER" ]; then
    print_success "Found existing $REVIEW_MARKER - skipping review stage."
    echo "Delete $REVIEW_MARKER to run review again."
else
    echo "Codex will review the entire codebase for bugs and improvements."
    echo ""
    echo "Tips:"
    echo "  - Codex is a 25+ year experienced Fullstack Developer"
    echo "  - It will review frontend/, backend/, and all config files"
    echo "  - You can guide the review process"
    echo -e "  - ${YELLOW}When done, press Ctrl+C to exit and finish${NC}"
    echo ""
    read -p "Press Enter to start Codex review..."

    CODEX_REVIEW_PROMPT="You are a Senior Fullstack Developer with 25+ years of experience.

WORKING DIRECTORY: $(pwd)

TASK: Review and fix the entire codebase for bugs, security issues, and quality.

STEP 1: Read all plan files to understand the project:
- '$PLAN_FILE' - main overview
- '$FRONTEND_PLAN' - frontend details
- '$BACKEND_PLAN' - backend details

STEP 2: Run builds and fix any errors:
- cd frontend && npm install && npm run build
- If build fails, analyze the root cause and FIX THE ERRORS before continuing
- Check for missing dependencies, incorrect imports, or configuration issues

STEP 3: Review frontend/ folder:
- Check all components for bugs and errors
- Verify imports are correct
- Check for TypeScript/JavaScript errors
- Ensure proper error handling
- Fix any issues you find

STEP 4: Review backend/ folder (if it exists):
- cd backend && npm install
- Run migrations if needed (npm run migrate)
- Check API endpoints work correctly
- Look for security vulnerabilities (SQL injection, XSS, etc.)
- Verify proper input validation
- Check error handling
- Fix any issues you find

STEP 5: Verify integration:
- Check frontend API calls match backend endpoints
- Verify CORS is configured correctly
- Ensure API base URLs are correct

STEP 6: Final verification:
- Run frontend build again: cd frontend && npm run build
- Ensure build succeeds with NO errors

STEP 7: Create '$REVIEW_MARKER' with a summary:
- What you reviewed
- Issues found and fixed
- Build status (MUST be passing)
- Any remaining recommendations

After creating the review file, say 'Review complete. User can press Ctrl+C to finish.'"

    codex --sandbox=workspace-write --full-auto "$CODEX_REVIEW_PROMPT"

    if [ ! -f "$REVIEW_MARKER" ]; then
        print_warning "Warning: Review may not have completed fully."
    else
        print_success "Code review completed!"
        echo ""
        echo "Review summary:"
        cat "$REVIEW_MARKER"
    fi
fi

print_success "Stage 4 Complete: Code review done."

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------

print_header "🎉 Agent Chain Complete!"

echo ""
echo "Generated project in: $PROJECT_PATH"
echo ""
echo "Project structure:"
echo ""

if command -v tree &> /dev/null; then
    tree -L 2 --dirsfirst 2>/dev/null || ls -la
else
    ls -la
    echo ""
    [ -d "frontend" ] && echo "frontend/:" && ls -la frontend/ 2>/dev/null
    [ -d "backend" ] && echo "backend/:" && ls -la backend/ 2>/dev/null
fi

echo ""
print_success "Your project is ready!"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_FOLDER"
echo "  2. Check frontend/README.md for frontend setup"
echo "  3. Check backend/README.md for backend setup"
echo "  4. Review .code_review_done for the review summary"
echo ""
