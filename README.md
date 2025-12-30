# Triforce AI

> Chain three AI agents to build full-stack applications automatically.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   CODEX     │───>│   GEMINI    │───>│   CLAUDE    │───>│   CODEX     │
│  Planning   │    │  Frontend   │    │  Backend    │    │  Review     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## What is Triforce AI?

Triforce AI chains together three powerful AI coding assistants to build complete applications:

1. **Codex (OpenAI)** - Plans the architecture through interactive Q&A
2. **Gemini (Google)** - Builds the frontend based on the plan
3. **Claude (Anthropic)** - Builds the backend and wires up the frontend
4. **Codex (OpenAI)** - Reviews code and fixes bugs

## Supported Versions

| CLI Tool | Package | Tested Version | Install Command |
|----------|---------|----------------|-----------------|
| Codex | `@openai/codex` | 0.36.0 | `npm install -g @openai/codex` |
| Gemini | `@google/gemini-cli` | 0.22.4 | `npm install -g @google/gemini-cli` |
| Claude | `@anthropic-ai/claude-code` | 2.0.76 | `npm install -g @anthropic-ai/claude-code` |

## Prerequisites

- **Node.js** v18+
- **npm** v9+

### Install CLI Tools

```bash
# Install all three CLI tools
npm install -g @openai/codex
npm install -g @google/gemini-cli
npm install -g @anthropic-ai/claude-code

# Authenticate each tool
codex login
claude login
# Gemini uses Google OAuth (will prompt on first run)
```

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/triforce-ai.git
cd triforce-ai

# Make executable
chmod +x agent_chain.sh

# Run!
./agent_chain.sh "Build a todo app with user authentication"
```

## Usage

### Basic Usage

```bash
./agent_chain.sh "Your project description"
```

### Example Prompts

```bash
./agent_chain.sh "Build a budget tracker with expense categories"
./agent_chain.sh "Create a blog platform with markdown support"
./agent_chain.sh "Build a real-time chat app with WebSocket"
./agent_chain.sh "Create a snake game with HTML, CSS, and JavaScript"
```

## How Each Stage Works

### Stage 1: Planning (Codex) - Interactive

Codex acts as a Technical Architect:
- Asks 2-3 clarifying questions about your project
- Creates three plan files:
  - `implementation_plan.md` - Main architecture
  - `frontend_plan.md` - Frontend details
  - `backend_plan.md` - Backend details

> **When done, press `Ctrl+C` to move to the next stage**

### Stage 2: Frontend (Gemini) - Interactive

Gemini builds the frontend:
- Reads `frontend_plan.md`
- Creates `frontend/` directory
- Uses appropriate CSS framework based on the project
- Creates placeholder API calls

> **When done, press `Ctrl+C` to move to the next stage**

### Stage 3: Backend (Claude) - Interactive

Claude builds the backend:
- Reads `backend_plan.md`
- Creates `backend/` directory
- Implements all API endpoints
- Wires up frontend to real API calls

> **When done, press `Ctrl+C` to move to the next stage**

### Stage 4: Code Review (Codex) - Interactive

Codex reviews as a Senior Developer:
- Checks for bugs and errors
- Fixes TypeScript/JavaScript issues
- Verifies frontend-backend integration
- Creates `.code_review_done` summary

> **When done, press `Ctrl+C` to finish**

## Output Structure

After running the script, your project will have this structure:

```
your-project/
├── implementation_plan.md    # Main architecture plan
├── frontend_plan.md          # Frontend specifications
├── backend_plan.md           # Backend specifications
├── frontend/
│   ├── src/
│   ├── package.json
│   └── README.md
├── backend/
│   ├── src/
│   ├── package.json
│   └── README.md
└── .code_review_done         # Review summary
```

## Resuming a Project

If you stop mid-way, just run the script again. It will:
- Skip stages that have completed artifacts
- Resume from where you left off

To regenerate a stage, delete its artifact:

```bash
rm implementation_plan.md  # Redo planning
rm -rf frontend/           # Redo frontend
rm -rf backend/            # Redo backend
rm .code_review_done       # Redo review
```

## Troubleshooting

### "codex: command not found"

```bash
npm install -g @openai/codex
codex login
```

### "gemini: command not found"

```bash
npm install -g @google/gemini-cli
```

### "claude: command not found"

```bash
npm install -g @anthropic-ai/claude-code
claude login
```

### Gemini hangs or can't create files

Make sure you're running from the project directory, not your home folder. The Gemini CLI needs to be run from a specific project directory.

### Stage doesn't move to next

Each stage runs interactively. When the AI finishes its work, press `Ctrl+C` to exit that stage and move to the next one.

## Electron GUI (Optional)

A desktop GUI is available in the `electron-app/` folder:

```bash
cd electron-app
npm install
npm start
```

This provides a visual terminal interface to run the agent chain.

## How It Works Internally

1. **Planning Stage**: Codex uses `--sandbox=workspace-write --full-auto` flags to create plan files
2. **Frontend Stage**: Gemini uses `-y -i` flags for YOLO mode with interactive prompt
3. **Backend Stage**: Claude uses `--dangerously-skip-permissions` flag
4. **Review Stage**: Codex reviews and fixes any issues found

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

## License

MIT
