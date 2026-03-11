# Nix-managed tool aliases
# All tools here are Nix system packages (system.nix) — no path prefix needed.

# ── File & directory ──────────────────────────────────────────────────────────
alias cat='bat'
alias ls='eza --color=always --git --no-filesize --icons=always -F'
alias ll='eza --color=always --long --git --icons=always -F'
alias la='eza --color=always --long --git --icons=always -Fa'
alias tree='eza --tree --icons=always'
alias yy='yazi'                          # file manager
alias du='dust'                          # visual disk usage tree

# ── Process / system ──────────────────────────────────────────────────────────
alias ps='procs'                         # coloured process tree
alias top='btm'                          # beautiful system monitor

# ── Git ───────────────────────────────────────────────────────────────────────
alias lg='lazygit'                       # full-featured git TUI
alias gu='gitui'                         # fast Rust git TUI
alias gd='git diff'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate --all'

# ── Diff ──────────────────────────────────────────────────────────────────────
alias diff='difft'                       # structural syntax-aware diff

# ── HTTP / API ────────────────────────────────────────────────────────────────
alias http='xh'                          # HTTPie-compatible HTTP client
alias https='xh --https'

# ── JSON ──────────────────────────────────────────────────────────────────────
alias json='jless'                       # interactive JSON viewer

# ── Kubernetes ────────────────────────────────────────────────────────────────
alias k='kubectl'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# ── Documentation ─────────────────────────────────────────────────────────────
alias tl='tldr'                          # fast community man pages
alias md='glow'                          # render Markdown in terminal

# ── Code stats ────────────────────────────────────────────────────────────────
alias loc='tokei'                        # lines of code by language

# ── Neovim ────────────────────────────────────────────────────────────────────
alias vi='nvim'
alias vim='nvim'
