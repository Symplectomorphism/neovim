#!/usr/bin/env bash
# Bootstrap for the modular Neovim config (Python/Julia/C++/AI agents) on RHEL 9.
# Review before running. Assumes sudo access and outbound internet (direct or proxied).
set -euo pipefail

# --- 1. Neovim itself -------------------------------------------------------
# RHEL9/EPEL's neovim package usually lags behind; this config needs >=0.11
# for vim.lsp.config()/vim.lsp.enable(). Use the official portable release
# instead of relying on EPEL's version.
NVIM_VER="v0.12.4" # match what's on the home machine; bump if you want latest
sudo mkdir -p /opt/nvim
curl -fL "https://github.com/neovim/neovim/releases/download/${NVIM_VER}/nvim-linux-x86_64.tar.gz" \
  | sudo tar -xz -C /opt/nvim --strip-components=1
echo 'export PATH="/opt/nvim/bin:$PATH"' | sudo tee /etc/profile.d/nvim.sh
# log out/in, or: source /etc/profile.d/nvim.sh

# --- 2. Build tools + libs used by plugin installs/parsers -----------------
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y git curl unzip tar gcc make

# ripgrep (required by Telescope live_grep) and fd (optional, faster find)
sudo dnf install -y epel-release || true
sudo dnf install -y ripgrep fd-find

# --- 3. Node.js (Copilot, tree-sitter-cli, ts_ls/html/cssls/jsonls) --------
sudo dnf module reset -y nodejs || true
sudo dnf module enable -y nodejs:20
sudo dnf install -y nodejs npm

# --- 4. tree-sitter CLI (needed by nvim-treesitter's main-branch installer) -
npm install -g tree-sitter-cli

# --- 5. clangd (C++/C LSP) ---------------------------------------------------
# Needs CRB (CodeReady Builder) or EPEL depending on RHEL minor version.
sudo dnf config-manager --set-enabled crb || true
sudo dnf install -y clang-tools-extra || echo "clang-tools-extra not found — check 'dnf search clangd' manually"

# --- 6. Julia (juliaup) -----------------------------------------------------
curl -fsSL https://install.julialang.org | sh -s -- --yes
# Reload shell / source juliaup env before continuing, then:
julia --project="$HOME/.julia/environments/nvim-lspconfig" -e \
  'using Pkg; Pkg.add(["LanguageServer", "SymbolServer", "StaticLint"])'
julia -e 'using Pkg; Pkg.add("JuliaFormatter")'

# --- 7. Clone the Neovim config ---------------------------------------------
# This script lives inside that same repo (scripts/rhel9_bootstrap.sh), so if
# you're running it from a clone you already have, this is a no-op.
# Private repo: use SSH (needs a key from this machine added to GitHub) or
# swap for the HTTPS URL + a personal access token / `gh auth login`.
if [ ! -d "$HOME/.config/nvim/.git" ]; then
  git clone git@github.com:Symplectomorphism/neovim.git "$HOME/.config/nvim"
fi

# --- 8. First launch ---------------------------------------------------------
# Run `nvim` once and wait: lazy.nvim installs plugins at the exact versions
# pinned in lazy-lock.json, then mason-tool-installer/mason-lspconfig pull
# pyright/ruff/texlab/html/cssls/jsonls/lua_ls/stylua/tex-fmt/debugpy/codelldb.
# This can take a few minutes the first time.

# --- Not handled by this script (do these yourself) -------------------------
# - Claude Code CLI (`claude`) and Antigravity CLI (`agy`): reinstall however
#   you originally installed them on your home machine — not something this
#   config manages.
# - GitHub Copilot auth: run `:Copilot auth` inside nvim once on this machine;
#   the auth token is per-machine and does not transfer via git.
# - Never run `nvim` with sudo — a past `sudo nvim` on the home machine left
#   root-owned files under ~/.cache/nvim that broke Treesitter for weeks.
