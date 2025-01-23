## NVIM
### Structure
```
nvim/
├── init.lua                    # Main entry point
├── lua/
│   └── config/
│       ├── init.lua            # Configuration initialization
│       ├── lsp/
│       │   ├── init.lua        # LSP setup
│       │   ├── configs.lua     # LSP server configurations
│       │   ├── keymaps.lua     # LSP keybindings
│       │   └── handlers.lua    # LSP handlers (format, etc)
│       └── options.lua         # Neovim options
└── colors/
    └── rosepine.vim            # Color scheme
```

### Required Deps:
```bash
go install golang.org/x/tools/gopls@latest
npm install -g typescript typescript-language-server
brew install lua-language-server
```

