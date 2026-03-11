# Neovim / LazyVim — Complete Field Guide

> **Distribution:** [LazyVim](https://www.lazyvim.org)
> **Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
> **Theme:** Catppuccin Mocha
> **AI:** Avante (Claude) + Supermaven inline completions

---

## Table of Contents

1. [First Launch](#1-first-launch)
2. [Core Concepts](#2-core-concepts)
3. [Essential Vim Motions](#3-essential-vim-motions)
4. [File Navigation](#4-file-navigation)
5. [LSP — Code Intelligence](#5-lsp--code-intelligence)
6. [Autocompletion](#6-autocompletion)
7. [AI Features (Avante + Supermaven)](#7-ai-features-avante--supermaven)
8. [Search & Replace](#8-search--replace)
9. [Git — LazyGit](#9-git--lazygit)
10. [Debugging — DAP](#10-debugging--dap)
11. [Testing — Neotest](#11-testing--neotest)
12. [Terminal & tmux Integration](#12-terminal--tmux-integration)
13. [Database UI](#13-database-ui)
14. [Language-Specific Tips](#14-language-specific-tips)
15. [Plugin Management](#15-plugin-management)
16. [Complete Key Reference](#16-complete-key-reference)
17. [Customisation](#17-customisation)

---

## 1. First Launch

```bash
nvim          # or vi / vim (aliased via .profile.nix)
```

On first start, lazy.nvim installs **all plugins** automatically (~2–3 min on first run).
Mason then installs LSP servers, formatters, and linters in the background.
Watch progress: `:Lazy` and `:Mason`.

### Checking health

```
:checkhealth          " check everything
:checkhealth lazy     " check plugin manager
:checkhealth mason    " check LSP installer
:checkhealth nvim     " check neovim core
```

### Updating

```
:Lazy update          " update all plugins
:Mason update         " update LSP servers / tools
```

---

## 2. Core Concepts

### Modes

| Mode | How to enter | What it does |
|------|-------------|--------------|
| **Normal** | `Esc` or `jk` | Navigate, issue commands |
| **Insert** | `i` `a` `o` `O` `I` `A` | Type text |
| **Visual** | `v` `V` `C-v` | Select text |
| **Visual-line** | `V` | Select whole lines |
| **Visual-block** | `C-v` | Column selection |
| **Command** | `:` | Run ex commands |
| **Replace** | `R` | Overwrite text |

### The Leader Key

`<leader>` = **Space**. Most LazyVim commands start with it.
Press `<Space>` and wait — **which-key** pops up showing all options.

```
<leader>f   → Find/Files
<leader>g   → Git
<leader>c   → Code (LSP actions)
<leader>b   → Buffer
<leader>x   → Diagnostics/Quickfix
<leader>t   → Terminal
<leader>a   → AI (Avante)
<leader>u   → UI toggles
<leader>q   → Quit/Session
```

---

## 3. Essential Vim Motions

### Navigation (Normal mode)

| Key | Motion |
|-----|--------|
| `h j k l` | ← ↓ ↑ → |
| `w` / `b` | Next / prev word |
| `W` / `B` | Next / prev WORD (space-separated) |
| `e` / `ge` | End of next / prev word |
| `0` / `^` / `$` | Line start / first char / end |
| `gg` / `G` | File start / end |
| `5G` | Jump to line 5 |
| `C-d` / `C-u` | Half-page down / up |
| `C-f` / `C-b` | Full page down / up |
| `zz` | Centre cursor in view |
| `%` | Jump to matching bracket |
| `*` / `#` | Find next/prev occurrence of word under cursor |
| `f<char>` | Jump to next `<char>` on line |
| `t<char>` | Jump before next `<char>` on line |
| `;` / `,` | Repeat / reverse last `f`/`t` |

### Text Objects (use with operators)

| Text Object | What |
|-------------|------|
| `iw` / `aw` | inner word / a word (with space) |
| `i"` / `a"` | inside quotes / with quotes |
| `i(` / `a(` | inside parens / with parens |
| `it` / `at` | inside tag / with tag (HTML/XML) |
| `ip` / `ap` | inside paragraph |
| `ib` / `iB` | inside `()` / `{}` block |

### Operators (combine with motions/text objects)

| Key | Operation |
|-----|-----------|
| `d` | Delete |
| `c` | Change (delete + insert) |
| `y` | Yank (copy) |
| `>` / `<` | Indent / unindent |
| `=` | Auto-indent |
| `g~` / `gu` / `gU` | Toggle / lower / upper case |

**Examples:**
```
dw     delete word
d$     delete to end of line
ciw    change inner word (works great with completions!)
yi"    yank text inside quotes
>ap    indent a paragraph
```

### Editing

| Key | Action |
|-----|--------|
| `i` / `a` | Insert before / after cursor |
| `I` / `A` | Insert at line start / end |
| `o` / `O` | New line below / above + insert |
| `s` / `S` | Substitute char / line |
| `x` | Delete char under cursor |
| `r<char>` | Replace single char |
| `u` / `C-r` | Undo / redo |
| `dd` | Delete line |
| `yy` | Yank line |
| `p` / `P` | Paste after / before |
| `J` | Join lines |
| `.` | Repeat last change |

---

## 4. File Navigation

### Neo-tree (file explorer)

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Neo-tree (left panel) |
| `<leader>E` | Focus Neo-tree |
| `a` | Add file/directory |
| `d` | Delete |
| `r` | Rename |
| `c` | Copy |
| `m` | Move |
| `y` | Copy filename to clipboard |
| `Y` | Copy relative path |
| `H` | Toggle hidden files |
| `/` | Search in tree |

### Telescope (fuzzy finder — the most used feature)

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files in project |
| `<leader>/` | Grep in project (live, fast) |
| `<leader>ff` | Find files |
| `<leader>fg` | Grep files |
| `<leader>fb` | Browse open buffers |
| `<leader>fr` | Recent files |
| `<leader>fR` | Recent files (cwd) |
| `<leader>fc` | Find config file |
| `<leader>fs` | Find symbol in workspace |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help tags |
| `<leader>sd` | Search diagnostics |
| `<leader>sG` | Grep ALL files (including untracked) |

**Inside Telescope:**
- `C-j` / `C-k` — move up/down
- `C-v` / `C-x` — open in vertical/horizontal split
- `C-t` — open in new tab
- `Tab` — select multiple files
- `Esc` or `C-c` — close

### Harpoon (quick file marks — like bookmarks for your current task)

Think of Harpoon as a persistent, per-session shortlist of the 4–5 files you're actively editing.

| Key | Action |
|-----|--------|
| `<leader>h` | Add current file to Harpoon |
| `C-e` | Open Harpoon menu |
| `C-1` through `C-4` | Jump to Harpoon file 1–4 |

### Buffers

| Key | Action |
|-----|--------|
| `<leader>bb` | Switch buffer (Telescope) |
| `<leader>bd` | Delete current buffer |
| `<leader>bD` | Delete buffer + window |
| `[b` / `]b` | Previous / next buffer |
| `<leader>bo` | Delete all other buffers |

### oil.nvim (edit filesystem like a buffer)

| Key | Action |
|-----|--------|
| `-` | Open parent directory |
| `<leader>o` | Open oil in float |

In an oil buffer: edit filenames to rename, `dd` to delete, `:w` to apply changes.

---

## 5. LSP — Code Intelligence

The Language Server Protocol gives you IDE-level intelligence.
Installed servers: Python, Rust, Go, Java, Kotlin, Scala, C/C++, Zig, TypeScript,
C#/.NET (OmniSharp), Swift (sourcekit), Bash, SQL, Nix, Docker, Terraform, YAML…

### Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references (in Telescope) |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation (press twice to enter the popup) |
| `gK` | Signature help (shows function signature while typing args) |
| `[d` / `]d` | Previous / next diagnostic |
| `[e` / `]e` | Previous / next error |
| `[w` / `]w` | Previous / next warning |

### Code Actions

| Key | Action |
|-----|--------|
| `<leader>ca` | Code actions (fix, refactor, organise imports…) |
| `<leader>cr` | Rename symbol (across entire project) |
| `<leader>cR` | Rename file (also updates references) |
| `<leader>cf` | Format file / selection |
| `<leader>cd` | Line diagnostics (floating popup) |
| `<leader>cF` | Force format with a specific formatter |

### Trouble (diagnostics panel)

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle Trouble (project diagnostics) |
| `<leader>xX` | Buffer diagnostics only |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |
| `[t` / `]t` | Previous / next Trouble item |

### Aerial (code outline / symbol tree)

| Key | Action |
|-----|--------|
| `<leader>cs` | Toggle symbol outline (Aerial) |
| `{` / `}` | Jump to previous / next symbol |

---

## 6. Autocompletion

LazyVim uses **blink.cmp** (fast Rust-based completion).

| Key | Action |
|-----|--------|
| `C-Space` | Trigger completion manually |
| `Tab` | Accept Supermaven AI suggestion (ghost text) |
| `C-j` | Accept next word of AI suggestion |
| `C-]` | Dismiss AI suggestion |
| `C-n` / `C-p` | Next / prev completion item |
| `C-b` / `C-f` | Scroll docs up / down |
| `C-e` | Dismiss completion menu |
| `CR` | Accept selected item |

**Completion sources (in priority order):**
1. Supermaven — AI ghost text (highest priority, `Tab` to accept)
2. LSP — symbols from language server
3. Snippets — LuaSnip / vsnip
4. Buffer — words in current buffer
5. Path — filesystem paths

### Snippets

Type a snippet prefix and select from the menu, or press `Tab` on a recognised shorthand.

| Language | Snippet example |
|----------|----------------|
| All | `todo` → `-- TODO:` |
| Lua | `fun` → function scaffold |
| Python | `def` → function with type hints |
| Go | `iferr` → `if err != nil { return err }` |
| Rust | `println` → `println!("")` |

---

## 7. AI Features (Avante + Supermaven)

### Supermaven — Inline Ghost Completions

Works like GitHub Copilot: as you type, a greyed-out suggestion appears.

```
Tab     → accept the entire suggestion
C-j     → accept just the next word
C-]     → dismiss
```

Supermaven is always active in insert mode with no setup required.

### Avante — AI Chat Panel (Claude)

Avante is like Cursor's AI panel, integrated into Neovim.
It uses Claude (configured in `lua/plugins/ai.lua`).
Set your API key: `export ANTHROPIC_API_KEY=sk-ant-...` (add to `~/.zshenv`).

| Key | Action |
|-----|--------|
| `<leader>aa` | Ask AI about selection or file |
| `<leader>ae` | Edit selection with AI instructions |
| `<leader>ar` | Refresh / regenerate last response |
| `<leader>at` | Toggle Avante panel |
| `<leader>ad` | Toggle debug mode |
| `<leader>ah` | Toggle hints |

**Workflow — editing with AI:**
1. Select code in Visual mode (`V` or `v`)
2. Press `<leader>ae`
3. Type your instruction: `"refactor to use async/await"` or `"add error handling"`
4. Review the diff — `co` to accept ours, `ct` to accept theirs, `cb` for both

**Workflow — asking questions:**
1. Position cursor in a file or select a block
2. Press `<leader>aa`
3. Type a question in the chat panel
4. The AI sees the full file context

---

## 8. Search & Replace

### In current file

| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next / prev match |
| `*` / `#` | Search word under cursor forward / backward |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace with confirmation |

### Spectre (project-wide find & replace)

| Key | Action |
|-----|--------|
| `<leader>sr` | Open Spectre (project search & replace) |

In Spectre:
- Type search pattern (supports regex)
- Type replacement
- `<leader>r` — replace all
- `dd` on a match — exclude that occurrence

### Flash (fast jump anywhere)

| Key | Action |
|-----|--------|
| `s` | Flash jump (type 2 chars, then label to jump) |
| `S` | Flash treesitter (jump to any AST node) |
| `r` (in operator mode) | Flash remote (action on distant text without moving) |

---

## 9. Git — LazyGit

### LazyGit TUI (full-featured)

| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit (floating terminal) |
| `<leader>gG` | LazyGit for current file history |
| `lg` | Open LazyGit from shell |

**Inside LazyGit:**
```
s           stage/unstage file
space       stage hunk
c           commit
P           push
p           pull
b           branch menu
d           diff
enter       view file diff
?           help (all keys)
q           quit
```

### Git signs & hunks (inline, in editor)

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / prev git hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage entire buffer |
| `<leader>ghR` | Reset entire buffer |
| `<leader>ghp` | Preview hunk (floating diff) |
| `<leader>ghb` | Blame line (shows commit message) |
| `<leader>ghB` | Toggle full git blame |
| `<leader>ghd` | Diff this file |
| `<leader>ghD` | Diff against last commit |

---

## 10. Debugging — DAP

DAP = Debug Adapter Protocol. Set up breakpoints and step through code
without leaving Neovim.

### Setup per language

Most languages just need the DAP adapter installed via Mason:
```
:Mason
" search for: python-debug-adapter, delve (Go), codelldb (Rust/C/C++), etc.
```

### Key bindings

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue (run to next breakpoint) |
| `<leader>dC` | Continue to cursor |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last config |
| `<leader>du` | Toggle DAP UI |
| `<leader>dw` | Widgets (hover variables) |
| `<leader>dt` | Terminate session |

### Python example

```python
# Set breakpoint programmatically (alternative to <leader>db)
import pdb; pdb.set_trace()
```

```
:lua require("dap-python").setup()    " first time
<leader>dc                             " start debugging
```

---

## 11. Testing — Neotest

Run tests for Python, Go, Rust without leaving the editor.

| Key | Action |
|-----|--------|
| `<leader>tt` | Run test nearest to cursor |
| `<leader>tT` | Run all tests in file |
| `<leader>tl` | Run last test |
| `<leader>ts` | Toggle test summary panel |
| `<leader>to` | Show test output |
| `<leader>tO` | Toggle output panel |
| `<leader>tS` | Stop test run |

---

## 12. Terminal & tmux Integration

### Built-in terminal (toggleterm)

| Key | Action |
|-----|--------|
| `<C-/>` | Toggle floating terminal |
| `<leader>ft` | New terminal (float) |
| `<leader>fT` | New terminal (current dir) |

### Seamless pane navigation (vim-tmux-navigator)

From inside Neovim — same keys as between tmux panes:

| Key | Action |
|-----|--------|
| `C-h` | Move to left pane (vim split or tmux pane) |
| `C-j` | Move to pane below |
| `C-k` | Move to pane above |
| `C-l` | Move to right pane |

This means you can split tmux horizontally, have Neovim in one pane and a shell in
another, and `C-h`/`C-l` moves between them seamlessly.

---

## 13. Database UI

Uses vim-dadbod-ui. Supports PostgreSQL, MySQL, SQLite, SQL Server, and more.

```
<leader>D    " toggle Database UI panel
```

**Setup:**
1. Open the Database UI: `<leader>D`
2. Press `o` to add a new connection
3. Enter a connection URL, e.g.:
   - PostgreSQL: `postgresql://user:pass@localhost:5432/dbname`
   - SQLite: `sqlite:///path/to/db.sqlite`
   - MySQL: `mysql://user:pass@localhost:3306/dbname`
4. Execute queries from a `.sql` buffer: `<leader>S` (execute query under cursor)

**SQL completion** is available in `.sql` files once connected.

---

## 14. Language-Specific Tips

### Swift
- LSP: **sourcekit-lsp** (ships with Xcode — install Xcode CLT: `xcode-select --install`)
- Works with SPM packages (`Package.swift`) and Xcode projects
- Hover (`K`) shows type info and docs
- `<leader>ca` → "Fix" to apply Swift compiler suggestions

### .NET / C#
- LSP: **OmniSharp** (install: `:MasonInstall omnisharp`)
- Works with `.sln` and `.csproj` files
- `<leader>ca` → Roslyn code actions (generate constructor, implement interface…)
- NuGet completion via omnisharp

### Python
- LSP: **pyright** (type checking) + **ruff** (linting/formatting)
- DAP: `pip install debugpy` in your venv
- Virtual env detection: activate your venv before opening nvim, or:
  ```
  :lua require("venv-selector").setup()   " if venv-selector installed
  ```

### Rust
- LSP: **rust-analyzer** (installed automatically by LazyVim Rust extra)
- Cargo integration: `<leader>ca` shows Cargo actions
- `C-Space` in `Cargo.toml` for version completion

### Go
- LSP: **gopls**
- Auto-imports on save
- `<leader>ca` → organise imports, add struct tags

### Zig
- LSP: **zls** (install: `:MasonInstall zls`)
- Tree-sitter: ✓ (syntax highlighting, textobjects)

### Mojo 🔥
- LSP: `mojo-lsp` (install: `modular install mojo`)
- Filetype: `.mojo` and `.(🔥)` files
- Uses Python-style syntax highlighting as fallback

### Bash / Shell
- LSP: **bash-language-server**
- Linting: **shellcheck** (install: `:MasonInstall shellcheck`)
- Formatting: **shfmt** (install: `:MasonInstall shfmt`)

### Docker
- LSP: **dockerls** for Dockerfile
- **docker-compose-language-service** for compose files
- Hover over base image names shows digest info

### Terraform / HCL
- LSP: **terraformls**
- Formatting: `terraform fmt` on save
- `<leader>ca` → Generate tfvars, add required providers

### Kubernetes / GitHub Actions / GitLab CI
- Managed via **yaml-language-server** with schema injection
- Open any `.github/workflows/*.yml` — schemas auto-applied
- Hover over any key for documentation
- `<leader>ca` → "Sort keys", "Fix indentation"

### Nix
- LSP: **nil** (nixpkgs formatter)
- Tree-sitter: full parsing
- Formatter: **nixpkgs-fmt** on save

### SQL
- LSP: **sqlls**
- Formatter: **sqlfluff**
- Run interactively: `<leader>D` (dadbod UI)

---

## 15. Plugin Management

### lazy.nvim commands

```
:Lazy             " open plugin manager UI
:Lazy update      " update all plugins
:Lazy sync        " install missing + remove unused
:Lazy clean       " remove unused plugins
:Lazy check       " check for updates without installing
:Lazy log         " view changelog for all plugins
:Lazy profile     " startup profiling (find slow plugins)
:Lazy help        " help
```

### Mason (LSP/linter/formatter installer)

```
:Mason                  " open Mason UI
:MasonInstall <name>    " install a specific tool
:MasonUpdate            " update all installed tools
:MasonLog               " view installation logs
```

---

## 16. Complete Key Reference

### Quick cheat sheet

```
──────────────────────────────────────────────────────────
  NAVIGATION
──────────────────────────────────────────────────────────
  <Space><Space>   find files (Telescope)
  <Space>/         live grep (search in project)
  <Space>e         file tree (Neo-tree)
  -                parent dir (oil.nvim)
  s                flash jump (type 2 chars + label)
  gd               go to definition
  gr               go to references
  K                hover docs
  [d / ]d          prev/next diagnostic

──────────────────────────────────────────────────────────
  CODE
──────────────────────────────────────────────────────────
  <Space>ca        code action
  <Space>cr        rename symbol
  <Space>cf        format
  <Space>cd        show diagnostic
  Tab              accept AI suggestion (supermaven)
  <Space>aa        ask AI (avante)
  <Space>ae        edit with AI

──────────────────────────────────────────────────────────
  GIT
──────────────────────────────────────────────────────────
  <Space>gg        LazyGit
  ]h / [h          next/prev hunk
  <Space>ghs       stage hunk
  <Space>ghb       blame line

──────────────────────────────────────────────────────────
  DEBUG
──────────────────────────────────────────────────────────
  <Space>db        toggle breakpoint
  <Space>dc        continue
  <Space>di / do   step in / step over

──────────────────────────────────────────────────────────
  BUFFERS & WINDOWS
──────────────────────────────────────────────────────────
  <Space>bb        switch buffer
  <Space>bd        close buffer
  C-h/j/k/l        move between splits + tmux panes
  <Space>wv / ws   split vertical / horizontal
  <Space>wd        close window
  <C-/>            toggle terminal

──────────────────────────────────────────────────────────
  MISC
──────────────────────────────────────────────────────────
  <Space>          which-key (shows all commands)
  <Space>u         UI toggles (line numbers, spell, etc.)
  <Space>l         Lazy (plugin manager)
  <Space>cm        Mason (LSP manager)
  :qa!             quit all without saving
  ZZ               save and quit
```

---

## 17. Customisation

All configuration lives in `~/.config/nix-darwin/modules/dotfiles/macos/.config/nvim/`:

```
lua/
├── config/
│   ├── lazy.lua       ← enable/disable LazyVim extras here
│   ├── options.lua    ← editor settings (tabsize, scrolloff, etc.)
│   ├── keymaps.lua    ← add/override keymaps
│   └── autocmds.lua   ← add autocommands
└── plugins/
    ├── ai.lua         ← Avante + Supermaven config
    ├── tools.lua      ← theme + extra plugins
    └── lsp.lua        ← LSP server configs (Swift, C#, Mojo…)
```

### Adding a new plugin

Create or edit a file in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
  {
    "author/plugin-name",
    event = "VeryLazy",           -- load lazily
    opts = { setting = "value" }, -- passed to setup()
    keys = {
      { "<leader>X", "<cmd>MyPlugin<cr>", desc = "My Plugin" },
    },
  },
}
```

Then apply the dotfiles change:
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
# ...and in nvim:
:Lazy sync
```

### Enabling a LazyVim extra

Edit `lua/config/lazy.lua`, uncomment or add:
```lua
{ import = "lazyvim.plugins.extras.lang.ruby" },
{ import = "lazyvim.plugins.extras.lang.php" },
{ import = "lazyvim.plugins.extras.lang.elixir" },
-- see: https://www.lazyvim.org/extras
```

### Overriding a plugin's options

```lua
-- lua/plugins/override.lua
return {
  {
    "folke/tokyonight.nvim",  -- override an existing plugin
    opts = { style = "storm" },
  },
}
```

### Disabling a plugin

```lua
return {
  { "plugin-you-dislike", enabled = false },
}
```

---

## Tips & Tricks

- **`ciw`** — "change inner word" — one of the most-used combos. Cursor anywhere on a word, type `ciw`, type the replacement. Done.
- **`.`** — repeat last change. Combined with `n` (next search match) this is incredibly powerful.
- **`*` then `cgn` then `.`** — find all occurrences of a word and change them one by one (safer than global replace).
- **`C-v` + select + `I` + type + `Esc`** — multi-line insert (column editing).
- **`q<letter>`** to record a macro, **`@<letter>`** to play it, **`@@`** to repeat.
- **`:norm @q`** — run macro on all selected lines.
- **`<leader>?`** — shows buffer-local keymaps.
- **`gx`** — open URL under cursor in browser.
- Hover docs popup: press **`K` twice** to enter the popup and scroll with `C-f`/`C-b`.
