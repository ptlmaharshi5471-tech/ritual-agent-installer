# 🔮 Ritual Sovereign Agent Installer

A production-quality one-click installer for the Ritual Foundation's Sovereign Agent with a beautiful terminal UI.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash: 5.0+](https://img.shields.io/badge/Bash-5.0+-green.svg)](#)
[![Platform: Ubuntu/WSL](https://img.shields.io/badge/Platform-Ubuntu%2FWSL-blue.svg)](#)

## 🚀 Quick Start

### Option 1: Clone & Run
```bash
git clone https://github.com/ptlmaharshi5471-tech/ritual-agent-installer.git
cd ritual-agent-installer
bash menu.sh
```

### Option 2: Curl & Run
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ptlmaharshi5471-tech/ritual-agent-installer/main/menu.sh)
```

## ✨ Features

- ✅ **One-Click Setup** - Installs all dependencies automatically
- ✅ **Modular Scripts** - Clean, reusable bash components
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Colorful UI** - Professional terminal interface with emojis
- ✅ **Error Handling** - Graceful failure messages
- ✅ **Progress Indicators** - Spinners and progress bars
- ✅ **Auto-Clone** - Fetches official Ritual repository
- ✅ **Environment Config** - Interactive setup wizard
- ✅ **Wallet Verification** - Balance and connectivity checks
- ✅ **Logging** - Complete deployment logs

## 📋 What Gets Installed

### System Dependencies
- git, curl, wget, unzip, jq
- build-essential, pkg-config, libssl-dev
- python3, python3-pip, python3-venv

### Development Tools
- **Foundry** - Smart contract development toolkit
- **uv** - Fast Python package manager
- **Ritual DApp Skills** - Official Ritual repository

## 🎯 Menu Options

```
========================================
        Ritual Agent Manager
========================================
1. ⚡ Install Everything
2. ⚙️  Configure Environment
3. 🚀 Deploy Sovereign Agent
4. 🔄 Update Official Ritual Repo
5. 💰 Check Wallet
6. 📋 View Logs
7. 🗑️  Uninstall
8. 🚪 Exit
```

## 🔧 Configuration

The installer creates `~/.ritual_env_agent1` with:

```bash
export RPC_URL="https://rpc.ritualfoundation.org"
export PRIVATE_KEY="your-private-key"
export OPENAI_API_KEY="your-openai-key"
export MODEL="gpt-4o-mini"
export HF_TOKEN="your-huggingface-token"
export HF_REPO_ID="your-repo-id"
export DEPOSIT_WEI="1000000000000000000"
export MIN_RITUAL_WALLET_WEI="500000000000000000"
export PROMPT="Your agent prompt"
```

## 📁 Project Structure

```
ritual-agent-installer/
├── README.md
├── LICENSE
├── .gitignore
├── menu.sh                 # Main menu
├── install.sh              # Installation orchestrator
├── deploy.sh               # Deployment script
├── update.sh               # Update ritual repo
├── uninstall.sh            # Cleanup script
├── logs.sh                 # Log viewer
├── .env.template           # Environment template
└── scripts/
    ├── colors.sh           # ANSI color utilities
    ├── utils.sh            # Common utilities
    ├── dependencies.sh     # System package installation
    ├── foundry.sh          # Foundry setup
    ├── uv.sh               # uv Python manager
    ├── ritual.sh           # Ritual repo operations
    ├── env.sh              # Environment configuration
    └── wallet.sh           # Wallet verification
```

## 🛠️ System Requirements

- **OS**: Ubuntu 20.04+ or WSL2
- **Bash**: 5.0+
- **Internet**: Required for downloads
- **Disk Space**: ~5GB for full installation

## 📝 Usage Examples

### Installation
```bash
# Run the main menu
bash menu.sh

# Or install everything at once
bash install.sh
```

### Configuration
```bash
# Configure environment variables
source scripts/env.sh
configure_environment
```

### Deployment
```bash
# Deploy the sovereign agent
bash deploy.sh
```

### Updates
```bash
# Update the Ritual repository
bash update.sh
```

### Logs
```bash
# View deployment logs
bash logs.sh
```

## ⚙️ Development

Each script is self-contained and can be sourced:

```bash
source scripts/colors.sh
source scripts/utils.sh
source scripts/dependencies.sh

# Use functions from the scripts
print_header "Installing Dependencies"
check_command "git"
install_package "curl"
```

## 🧪 Testing

```bash
# Test in a clean environment
docker run -it ubuntu:22.04 bash -c "
  apt-get update && apt-get install -y git curl
  git clone https://github.com/ptlmaharshi5471-tech/ritual-agent-installer.git
  cd ritual-agent-installer
  bash menu.sh
"
```

## 🐛 Troubleshooting

### Installation Fails
```bash
# Check logs
bash logs.sh

# Run with debug mode
bash -x menu.sh
```

### Wallet Balance Issues
```bash
# Verify configuration
source ~/.ritual_env_agent1
echo $PRIVATE_KEY
echo $RPC_URL
```

### Python Environment Issues
```bash
# Recreate virtual environment
cd ~/projects/ritual-dapp-skills/examples/sovereign-agent
rm -rf .venv
uv venv
uv sync
```

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please:
1. Test thoroughly
2. Follow the modular structure
3. Add comments for clarity
4. Test on both Ubuntu and WSL2

## 📞 Support

For issues with:
- **This Installer** - Open an issue on GitHub
- **Ritual Agent** - Visit https://github.com/ritual-foundation/ritual-dapp-skills

## 🔗 Links

- [Ritual Foundation](https://ritual.foundation)
- [Ritual DApp Skills](https://github.com/ritual-foundation/ritual-dapp-skills)
- [Foundry](https://book.getfoundry.sh)
- [uv Python Manager](https://astral.sh/uv/)

---

**Made with ❤️ for the Ritual community**
