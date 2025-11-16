# Virgin Project

Modern web server project with Express.js

## 🚀 Quick Start

```bash
# Start server
./scripts/server/start-server.sh

# Stop server  
./scripts/server/kill-server.sh

# Safe restart
./scripts/server/safe-restart.sh
```

## 📁 Project Structure

```
virgin/
├── index.html          # Main entry point (public website)
├── app/                # Application code
│   ├── server.js
│   ├── package.json
│   └── node_modules/
├── scripts/            # Management scripts
│   ├── server/        # Server management
│   ├── setup/         # Configuration
│   └── utils/         # Utilities
├── docs/              # Documentation
├── views/             # HTML templates
├── public/            # Static assets
└── logs/              # Log files
```

## 📚 Documentation

- [docs/README.main.md](docs/README.main.md) - Full documentation
- [docs/QUICK_START.md](docs/QUICK_START.md) - Getting started
- [docs/STRUCTURE.md](docs/STRUCTURE.md) - Project structure
- [docs/SAFE_RESTART.md](docs/SAFE_RESTART.md) - Safe restart guide

## 🛠️ Available Scripts

### Server Management
- `scripts/server/start-server.sh` - Start server
- `scripts/server/kill-server.sh` - Stop server
- `scripts/server/restart-servers.sh` - Quick restart
- `scripts/server/safe-restart.sh` - Safe restart (5-step process)

### Setup
- `scripts/setup/setup-structure.sh` - Create project structure
- `scripts/setup/setup-aliases.sh` - Setup bash aliases
- `scripts/setup/setup-autostart.sh` - Configure autostart

### Utilities
- `scripts/utils/test-environment.sh` - Test environment
- `scripts/utils/show-structure.sh` - Show structure

## ⚙️ Configuration

Server runs on: `http://localhost:3000`

Health check: `http://localhost:3000/healthz`

## 📄 License

MIT License - see [docs/LICENSE](docs/LICENSE)
