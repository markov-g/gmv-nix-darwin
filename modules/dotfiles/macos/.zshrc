# Enable Powerlevel10k instant prompt. Must stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set TERM only outside tmux — inside tmux, let tmux's default-terminal (tmux-256color) win.
[[ -z "$TMUX" ]] && export TERM="xterm-256color"

# ── Force compinit to skip the security check ────────────────────────────────
# antigen bundle brew re-adds /opt/homebrew to fpath during bundle processing.
# That dir is owned by the admin user — compinit flags it insecure for everyone
# else. Intercepting compinit and passing -u bypasses the check unconditionally,
# regardless of what antigen puts in fpath before calling it.
function compinit() {
  unfunction compinit
  autoload -Uz compinit
  compinit -u "$@"
}

# ── Default editor ───────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── Plugin manager (antigen) ──────────────────────────────────────────────────
source ~/PACKAGEMGMT/Homebrew/share/antigen/antigen.zsh

# ── oh-my-zsh via antigen ─────────────────────────────────────────────────────
# Note: p10k theme is configured via ~/.p10k.zsh (run `p10k configure` to regenerate).
# POWERLEVEL9K_* vars are NOT read by powerlevel10k — only p9k reads them.
export ZSH_DISABLE_COMPFIX=true

antigen use oh-my-zsh
antigen bundle robbyrussell/oh-my-zsh lib/

antigen bundle command-not-found
antigen bundle cp
antigen bundle docker
antigen bundle git
antigen bundle pip
antigen bundle autojump
antigen bundle brew
antigen bundle common-aliases
antigen bundle git-extras
antigen bundle git-flow
antigen bundle npm
antigen bundle macos
antigen bundle python
antigen bundle vi-mode
antigen bundle web-search
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh
#antigen bundle tarruda/zsh-autosuggestions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle https://github.com/spwhitt/nix-zsh-completions.git

# Theme
antigen theme romkatv/powerlevel10k

antigen apply

# ── Paste safety: bracketed paste ─────────────────────────────────────────────
# Pasted text (incl. multi-line) is inserted as ONE inert buffer. Embedded
# newlines do NOT execute; you review and hit Enter yourself. This is the fix
# for the podman-rmi clipboard incident.
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# If `bindkey | grep bracketed` shows nothing in a fresh shell, also add:
# bindkey '^[[200~' bracketed-paste

# ── fzf shell integration ─────────────────────────────────────────────────────
# MUST be after antigen apply — antigen triggers compinit, and fzf's completion.zsh
# calls compdef to register the ** trigger. compdef only exists post-compinit.
# The FZF_*_COMMAND / FZF_DEFAULT_OPTS env vars stay in .zprofile (order-independent).
source <(fzf --zsh)

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1"; }

_fzf_comprun() {
  local command=$1; shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${{}'"  "$@" ;;
    ssh)          fzf --preview 'dig {}'             "$@" ;;
    *)            fzf --preview "if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi" "$@" ;;
  esac
}

# fzf-git.sh (cloned by home.nix activation at bootstrap)
[ -f ~/.fzf-git.sh/fzf-git.sh ] && source ~/.fzf-git.sh/fzf-git.sh

# ── Language / toolchain env ──────────────────────────────────────────────────
# Note: RUSTUP_HOME, CARGO_HOME, PATH for cargo are in .zshenv (always sourced).

# Tell sops CLI where the age key lives (sops-nix uses home.nix's keyFile setting
# for activation; this is only for interactive sops invocations).
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

## History format
export HISTTIMEFORMAT="%d/%m/%y %T "

# ── Home-Manager session vars (Determinate Nix) ───────────────────────────────
[[ -r /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ]] && \
  source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh

# ── Nix / nix-darwin shortcuts ────────────────────────────────────────────────
alias nix-search="nix search nixpkgs"
alias nix-install="nix profile install"
alias nix-upgrade="nix profile upgrade"
alias nix-flake-update="nix flake update"
alias nix-gc="nix-collect-garbage -d"
alias darwin-re="sudo -i darwin-rebuild switch --flake ~/.config/nix-darwin"
alias darwin-cfg="code ~/.config/nix-darwin/flake.nix"
alias hm-cfg="code ~/.config/nix-darwin/modules/home.nix"

# ── Aliases ───────────────────────────────────────────────────────────────────

# editors
alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs -nw"
alias emacs-dbg="/Applications/Emacs.app/Contents/MacOS/Emacs -nw --debug-init"
alias vi='vim'

# safe file ops (rm is overridden by the function below; no alias needed)
alias cp='cp -ivp'
alias mv='mv -iv'
alias mkdir='mkdir -p'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias home='cd ~'
alias f='open -a Finder ./'

# system info
alias ps='ps ax'
alias pg='ps -aux | grep'
alias du='du -h'
alias du1='du -h --max-depth=1'
alias df='df -kh'
alias da='date "+%Y-%m-%d %A    %T %Z"'
alias mountedinfo='df -h'
alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'
alias topForever='top -l 9999999 -s 10 -o cpu'
alias ttop="top -R -F -s 10 -o rsize"

# network
alias myip='curl ip.appspot.com'
alias netCons='lsof -i'
alias flushDNS='dscacheutil -flushcache'
alias lsock='sudo /usr/sbin/lsof -i -P'
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'
alias openPorts='sudo lsof -i | grep LISTEN'
alias ipInfo0='ipconfig getpacket en0'
alias ipInfo1='ipconfig getpacket en1'

# macOS
alias hibernateon="sudo pmset -a hibernatemode 3"
alias hibernateoff="sudo pmset -a hibernatemode 0"
alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"
alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'
alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
alias mountReadWrite='/sbin/mount -uw /'
alias screensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'

# package managers / tools
alias port='port -v'
alias fink='fink -v'
alias less='less -FSRXc'
alias un='tar -zxvf'
alias c='clear'
alias ping='ping -c1 -s512'
alias j='jobs -l'
alias h='fc -il 1'
alias path='echo -e ${PATH//:/\\n}'
alias mx='chmod a+x'
alias 644='chmod 644'
alias 755='chmod 755'

# ── Functions ─────────────────────────────────────────────────────────────────

# Move to Trash instead of permanent delete
function rm() {
  local path
  for path in "$@"; do
    if [[ "$path" = -* ]]; then :
    else
      local dst=${path##*/}
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(/bin/date +%H-%M-%S)
      done
      /bin/mv -v "$path" ~/.Trash/"$dst"
    fi
  done
}

# cd with pwd echo — no argument goes to $HOME
cd() { builtin cd "${1:-$HOME}" && pwd; }

# Extract most archive formats
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1"    ;;
      *.tar.gz)  tar xzf "$1"    ;;
      *.bz2)     bunzip2 "$1"    ;;
      *.rar)     unrar e "$1"    ;;
      *.gz)      gunzip "$1"     ;;
      *.tar)     tar xf "$1"     ;;
      *.tbz2)    tar xjf "$1"    ;;
      *.tgz)     tar xzf "$1"    ;;
      *.zip)     unzip "$1"      ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1"       ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Change to current Finder window directory
cdf() {
  local target
  target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
  if [ -n "$target" ]; then
    cd "$target" && pwd
  else
    echo 'No Finder window found' >&2
  fi
}

# Colorized man pages
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

repeat-cmd() {
  local i max=$1; shift
  for ((i=1; i <= max; i++)); do eval "$@"; done
}

confirm() {
  echo -n "$@ [y/n] "; read ans
  case "$ans" in y*|Y*) return 0 ;; *) return 1 ;; esac
}

my_ps() { ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command; }

# ── Custom utility functions (curated from a community gist) ─────────────────
# Dropped from the source gist: webshare (serves cwd over unauthenticated
# HTTP), cbjson (needs python3, which isn't Nix-declared in system.nix).
# `port` was renamed to `portcheck` below -- this file already aliases `port`
# to MacPorts' `port -v`. `extract` and `myip` are skipped -- equivalents
# already exist above.
#
# Colors are local to this file (not exported), so child processes never
# inherit generic env names like $C_RED.
C_RED=$'\e[0;31m'
C_GREEN=$'\e[0;32m'
C_YELLOW=$'\e[0;33m'
C_CYAN=$'\e[0;36m'
C_MAGENTA=$'\e[0;35m'
C_NC=$'\e[0m'

myfuncs() {
    echo "${C_CYAN}====================================================${C_NC}"
    echo "${C_MAGENTA}          Custom ZSH Utilities Cheat Sheet${C_NC}"
    echo "${C_CYAN}====================================================${C_NC}"
    echo "Run any command with ${C_YELLOW}-h${C_NC} or ${C_YELLOW}help${C_NC} for detailed usage."
    echo ""
    echo "${C_YELLOW}File & Directory Ops${C_NC}"
    echo "  ${C_GREEN}mkcd${C_NC}       - Create a directory and enter it immediately"
    echo "  ${C_GREEN}ql${C_NC}         - Open a file in macOS Quick Look"
    echo ""
    echo "${C_YELLOW}Developer Tools${C_NC}"
    echo "  ${C_GREEN}glit${C_NC}       - One-step git add, commit, push, and cleanup"
    echo "  ${C_GREEN}genpass${C_NC}    - Generate a secure password & copy to clipboard"
    echo ""
    echo "${C_YELLOW}Networking${C_NC}"
    echo "  ${C_GREEN}portcheck${C_NC}  - Check what's running on a port (and optionally kill it)"
    echo "  ${C_GREEN}pingmap${C_NC}    - Detailed network latency and status breakdown"
    echo ""
    echo "${C_YELLOW}Productivity & System${C_NC}"
    echo "  ${C_GREEN}todo${C_NC}       - Manage a persistent CLI task list"
    echo "  ${C_GREEN}countdown${C_NC}  - Start a timer with UI notifications (supports s/m/h)"
    echo "  ${C_GREEN}keepawake${C_NC}  - Prevent your Mac from sleeping"
    echo "  ${C_GREEN}weather${C_NC}    - Get terminal weather forecast"
    echo "${C_CYAN}====================================================${C_NC}"
}

mkcd() {
    if [[ "$1" == "help" || "$1" == "-h" || -z "$1" ]]; then
        echo "${C_CYAN}mkcd${C_NC}: Create a directory and enter it in one step."
        echo "Usage: ${C_YELLOW}mkcd <directory_name>${C_NC}"
        return 0
    fi
    mkdir -p "$1" && cd "$1" || return
    echo "${C_GREEN}Directory created. Now in: $(pwd)${C_NC}"
}

ql() {
    if [[ "$1" == "help" || "$1" == "-h" || -z "$1" ]]; then
        echo "${C_CYAN}ql${C_NC}: Open file(s) in macOS Quick Look (like pressing Space in Finder)."
        echo "Usage: ${C_YELLOW}ql <file> [file2] ...${C_NC}"
        return 0
    fi
    qlmanage -p "$@" >/dev/null 2>&1 &
}

glit() {
    if [[ "$1" == "help" || "$1" == "-h" || -z "$1" ]]; then
        echo "${C_CYAN}glit${C_NC}: The lazy way to git."
        echo "Usage:"
        echo "  ${C_YELLOW}glit <message>${C_NC}       - Add all, commit, and push (quotes optional)"
        echo "  ${C_YELLOW}glit amend${C_NC}           - Add all, amend last commit, and safely force push"
        echo "  ${C_YELLOW}glit wip${C_NC}             - Add all, commit as 'WIP' with timestamp, and push"
        echo "  ${C_YELLOW}glit undo${C_NC}            - Undo the last local commit (keeps your file changes)"
        echo "  ${C_YELLOW}glit clean${C_NC}           - Delete local branches merged to main/master"
        echo "  ${C_YELLOW}glit merge <branch>${C_NC}  - Fetch and merge a remote branch into your current branch"
        echo "  ${C_YELLOW}glit status${C_NC}          - Show full git status"
        echo "  ${C_YELLOW}glit log [num]${C_NC}       - Show a colorized git history tree"
        echo ""
        echo "${C_YELLOW}Quick Status:${C_NC}"
        git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git status -s || echo "Not a git repository."
        return 0
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${C_RED}Error: You are not in a git repository.${C_NC}"
        return 1
    fi

    local branch_name=$(git rev-parse --abbrev-ref HEAD)

    case "$1" in
        "amend")
            echo "${C_CYAN}Adding changes and amending last commit...${C_NC}"
            git add .
            git commit --amend --no-edit
            echo "${C_CYAN}Force pushing to origin $branch_name...${C_NC}"
            git push origin "$branch_name" --force-with-lease
            echo "${C_GREEN}Amend & push complete!${C_NC}"
            ;;
        "undo")
            echo "${C_YELLOW}Undoing last commit (your files remain changed)...${C_NC}"
            git reset HEAD~1
            echo "${C_GREEN}Last commit undone. You can now make changes and commit again.${C_NC}"
            ;;
        "wip")
            echo "${C_CYAN}Committing as WIP...${C_NC}"
            git add .
            git commit -m "WIP: $(date '+%Y-%m-%d %H:%M:%S')"
            git push origin "$branch_name"
            echo "${C_GREEN}WIP pushed!${C_NC}"
            ;;
        "clean")
            echo "${C_CYAN}Searching for merged local branches...${C_NC}"
            local merged_branches=$(git branch --merged | egrep -v "(^\*|master|main|dev)")
            if [[ -z "$merged_branches" ]]; then
                echo "${C_GREEN}Your local repository is already clean!${C_NC}"
            else
                echo "$merged_branches" | xargs git branch -d
                echo "${C_GREEN}Cleaned up merged branches!${C_NC}"
            fi
            ;;
        "status")
            echo "${C_CYAN}Current Git Status for branch '${C_YELLOW}$branch_name${C_CYAN}':${C_NC}"
            echo "------------------------------------------------------------"
            git status
            ;;
        "merge")
            local target_branch=$2
            if [[ -z "$target_branch" ]]; then
                echo "${C_RED}Error: Please specify a branch to merge.${C_NC}"
                echo "Usage: ${C_YELLOW}glit merge <branch_name>${C_NC}"
                return 1
            fi

            echo "${C_CYAN}Fetching latest changes for '$target_branch' from origin...${C_NC}"
            git fetch origin "$target_branch"

            echo "${C_CYAN}Merging origin/$target_branch into $branch_name...${C_NC}"
            if git merge "origin/$target_branch"; then
                echo "${C_GREEN}Successfully merged '$target_branch' into '$branch_name'!${C_NC}"
            else
                echo ""
                echo "${C_RED}Merge conflicts detected!${C_NC}"
                echo "Resolve the conflicts in your editor, then run ${C_YELLOW}glit \"Merge resolution\"${C_NC} to finish."
            fi
            ;;
        "log")
            local count=${2:-15}
            git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n "$count"
            ;;
        *)
            echo "${C_CYAN}Executing: git add .${C_NC}"
            git add .
            echo "${C_CYAN}Executing: git commit -m \"$*\"${C_NC}"
            git commit -m "$*"
            echo "${C_CYAN}Executing: git push origin $branch_name${C_NC}"
            git push origin "$branch_name"
            echo "${C_GREEN}All done! Code pushed successfully.${C_NC}"
            ;;
    esac
}

genpass() {
    if [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "${C_CYAN}genpass${C_NC}: Generate a secure password and copy to clipboard."
        echo "Usage: ${C_YELLOW}genpass [length]${C_NC}"
        echo "Example: genpass 24"
        return 0
    fi

    local len=${1:-16}
    local pass=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9!@#$%^&*' | fold -w "$len" | head -n 1)

    echo "$pass" | pbcopy
    echo "${C_GREEN}Password generated and copied to clipboard!${C_NC}"
    echo "Length: $len chars"
}

# Renamed from the gist's `port` -- this file already aliases `port` to
# MacPorts' `port -v` (see bin/update-macports, bin/install-macports.sh).
portcheck() {
    if [[ "$1" == "help" || "$1" == "-h" || -z "$1" ]]; then
        echo "${C_CYAN}portcheck${C_NC}: See what's running on a TCP port and optionally kill it."
        echo "Usage: ${C_YELLOW}portcheck <number> [kill]${C_NC}"
        echo "Examples:"
        echo "  portcheck 8080       (Views processes on port 8080)"
        echo "  portcheck 3000 kill  (Kills the process running on port 3000)"
        return 0
    fi

    local target_port=$1
    if [[ "$2" == "kill" ]]; then
        echo "${C_RED}Attempting to kill process on port $target_port...${C_NC}"
        local pid=$(lsof -t -i:"$target_port")
        if [[ -n "$pid" ]]; then
            kill -9 $pid
            echo "${C_GREEN}Process $pid killed successfully.${C_NC}"
        else
            echo "${C_YELLOW}No process found running on port $target_port.${C_NC}"
        fi
    else
        echo "${C_CYAN}Processes listening on port $target_port:${C_NC}"
        lsof -i :"$target_port" || echo "${C_YELLOW}No active processes on this port.${C_NC}"
    fi
}

pingmap() {
    if [[ "$1" == "help" || "$1" == "-h" || -z "$1" ]]; then
        echo "${C_CYAN}pingmap${C_NC}: Detailed connection latency breakdown."
        echo "Usage: ${C_YELLOW}pingmap <url>${C_NC}"
        echo "Example: pingmap google.com"
        return 0
    fi

    local url="$1"
    [[ "$url" != http* ]] && url="https://$url"

    echo "${C_CYAN}Mapping network route to: $url${C_NC}"
    echo "----------------------------------------"
    curl -w "  HTTP Status   : %{http_code}\n  DNS Lookup    : %{time_namelookup}s\n  TCP Connect   : %{time_connect}s\n  TLS Handshake : %{time_appconnect}s\n  Pre-Transfer  : %{time_pretransfer}s\n  First Byte    : %{time_starttransfer}s\n----------------------------------------\n  ${C_GREEN}Total Time    : %{time_total}s${C_NC}\n\n" -o /dev/null -s "$url"
}

todo() {
    local todo_file="$HOME/.todo_list.txt"
    touch "$todo_file"

    _todo_check_bounds() {
        local target=$1
        local max_line
        max_line=$(wc -l < "$todo_file" | awk '{print $1}')
        if (( target > max_line || target < 1 )); then
            echo "${C_RED}Task number $target not found.${C_NC}"
            return 1
        fi
        return 0
    }

    case "$1" in
        "help"|"-h"|"--help")
            echo "${C_CYAN}CLI Todo List -- Help Menu${C_NC}"
            echo "Usage: todo [command] [arguments]"
            echo ""
            echo "  ${C_YELLOW}todo <text>${C_NC}              Add a task"
            echo "  ${C_YELLOW}todo list${C_NC}                Display tasks"
            echo "  ${C_YELLOW}todo done <num>${C_NC}        Mark task completed"
            echo "  ${C_YELLOW}todo undo <num>${C_NC}        Revert task to pending"
            echo "  ${C_YELLOW}todo edit <num> <txt>${C_NC}  Update task"
            echo "  ${C_YELLOW}todo rm <num>${C_NC}          Delete task"
            echo "  ${C_YELLOW}todo clear done${C_NC}        Remove completed tasks"
            echo "  ${C_YELLOW}todo clear${C_NC}             Wipe entire list"
            ;;
        "list"|"")
            if [ ! -s "$todo_file" ]; then
                echo "${C_GREEN}No tasks.${C_NC}"
            else
                echo "${C_CYAN}Your Todo List:${C_NC}"
                local count=1
                while IFS= read -r line || [ -n "$line" ]; do
                    [[ -z "${line//[[:space:]]/}" ]] && continue

                    if [[ "$line" == *"[ ]"* ]]; then
                        line="${line//"[ ]"/${C_YELLOW}[ ]${C_NC}}"
                    elif [[ "$line" == *"[x]"* ]]; then
                        line="${line//"[x]"/${C_GREEN}[x]${C_NC}}"
                    fi

                    printf "%2d. %s\n" "$count" "$line"
                    ((count++))
                done < "$todo_file"

                if [ "$count" -eq 1 ]; then
                    echo "${C_GREEN}No tasks.${C_NC}"
                fi
            fi
            ;;
        "done")
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                _todo_check_bounds "$2" || return 1
                sed -i "" "${2}s/\[ \]/\[x\]/" "$todo_file"
                echo "${C_GREEN}Task $2 marked as done!${C_NC}"
            else
                echo "${C_YELLOW}Usage: todo done <task_number>${C_NC}"
            fi
            ;;
        "undo")
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                _todo_check_bounds "$2" || return 1
                sed -i "" "${2}s/\[x\]/\[ \]/" "$todo_file"
                echo "${C_YELLOW}Task $2 marked as pending!${C_NC}"
            else
                echo "${C_YELLOW}Usage: todo undo <task_number>${C_NC}"
            fi
            ;;
        "rm")
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                _todo_check_bounds "$2" || return 1
                sed -i "" "${2}d" "$todo_file"
                echo "${C_RED}Task $2 deleted!${C_NC}"
            else
                echo "${C_YELLOW}Usage: todo rm <task_number>${C_NC}"
            fi
            ;;
        "edit")
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ && -n "$3" ]]; then
                local line_num=$2
                _todo_check_bounds "$line_num" || return 1
                shift 2
                sed -i "" "${line_num}s|.*|- [ ] $*|" "$todo_file"
                echo "${C_CYAN}Task $line_num updated!${C_NC}"
            else
                echo "${C_YELLOW}Usage: todo edit <task_number> <new text>${C_NC}"
            fi
            ;;
        "clear")
            if [ "$2" = "done" ]; then
                grep -v '\[x\]' "$todo_file" > "$todo_file.tmp"
                mv "$todo_file.tmp" "$todo_file"
                echo "${C_GREEN}Cleared completed tasks!${C_NC}"
            elif [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                echo "${C_YELLOW}Did you mean 'todo rm $2'?${C_NC}"
            elif [ -n "$2" ]; then
                echo "${C_YELLOW}Unknown argument. Use 'todo clear done' or 'todo clear'.${C_NC}"
            else
                echo -n "${C_RED}Wipe ENTIRE todo list? (y/N): ${C_NC}"
                read -r response
                if [[ "$response" == [Yy]* ]]; then
                    rm -f "$todo_file" && touch "$todo_file"
                    echo "${C_RED}Todo list wiped completely clean!${C_NC}"
                else
                    echo "${C_CYAN}Action aborted.${C_NC}"
                fi
            fi
            ;;
        -*)
            return 0
            ;;
        *)
            echo "- [ ] $*" >> "$todo_file"
            echo "${C_GREEN}Task added!${C_NC}"
            ;;
    esac
}

countdown() {
    if [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "${C_CYAN}countdown${C_NC}: A simple terminal timer with notifications."
        echo "Usage: ${C_YELLOW}countdown <time>[s|m|h]${C_NC}"
        echo "Examples: countdown 45, countdown 5m, countdown 1h"
        return 0
    fi

    local input=${1:-60}
    local seconds=0

    if [[ $input == *m ]]; then seconds=$((${input%m} * 60))
    elif [[ $input == *h ]]; then seconds=$((${input%h} * 3600))
    elif [[ $input == *s ]]; then seconds=${input%s}
    else seconds=$input; fi

    if ! [[ "$seconds" =~ ^[0-9]+$ ]]; then
        echo "${C_RED}Invalid time format.${C_NC} Use numbers, optionally followed by m or h."
        return 1
    fi

    echo "${C_CYAN}Starting timer for $input...${C_NC}"
    while [ "$seconds" -gt 0 ]; do
        printf "\r${C_YELLOW}Time remaining: %02d:%02d${C_NC}\033[0K" $((seconds/60)) $((seconds%60))
        sleep 1
        : $((seconds--))
    done

    printf "\r\033[0K"
    echo "${C_GREEN}Time's up! ($input)${C_NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"Your $input timer has finished!\" with title \"Countdown\" sound name \"Glass\""
        say "Timer is done" >/dev/null 2>&1 &!
    else
        echo -e "\a"
    fi
}

keepawake() {
    if [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "${C_CYAN}keepawake${C_NC}: Prevent your Mac from sleeping."
        echo "Usage: ${C_YELLOW}keepawake [time | -p PID | -c command | stop]${C_NC}"
        echo ""
        echo "Options:"
        echo "  ${C_YELLOW}[time]${C_NC}       Keep awake for duration (e.g., 2h, 30m) and notify when done"
        echo "  ${C_YELLOW}-p <PID>${C_NC}     Keep awake until a Process ID finishes, then notify"
        echo "  ${C_YELLOW}-c <cmd>${C_NC}     Run a command, keep awake until it completes, then notify"
        echo "  ${C_YELLOW}-s${C_NC}           System-only mode: keep tasks running, but let the screen turn off"
        echo "  ${C_YELLOW}stop${C_NC}         Kill any existing keepawake sessions running in the background"
        echo "  ${C_YELLOW}(none)${C_NC}       Keep awake indefinitely (Ctrl+C to stop)"
        echo ""
        echo "Examples:"
        echo "  keepawake -c npm run build"
        echo "  keepawake -s 2h"
        return 0
    fi

    _keepawake_notify_done() {
        local msg="$1"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            osascript -e "display notification \"$msg\" with title \"Keepawake\" sound name \"Glass\""
            say "Task finished" >/dev/null 2>&1 &!
        else
            echo -e "\a"
        fi
    }

    if [[ "$1" == "stop" ]]; then
        killall caffeinate 2>/dev/null
        echo "${C_GREEN}Stopped all active keepawake sessions. Mac can sleep normally.${C_NC}"
        return 0
    fi

    local flags="-dism"
    if [[ "$1" == "-s" || "$1" == "--system" ]]; then
        flags="-ism"
        shift
        echo "${C_YELLOW}System-only mode: display will sleep, but background processes will run.${C_NC}"
    fi

    if [[ -z "$1" ]]; then
        echo "${C_GREEN}Mac is now caffeinated. Press Ctrl+C to let it sleep.${C_NC}"
        caffeinate $flags
        echo "${C_CYAN}Mac can sleep normally now.${C_NC}"
        return 0
    fi

    case "$1" in
        -p|--pid)
            local pid=$2
            if [[ -z "$pid" || ! "$pid" =~ ^[0-9]+$ ]]; then
                echo "${C_RED}Error: Please provide a valid Process ID.${C_NC}"
                return 1
            fi
            echo "${C_GREEN}Mac will stay awake until process $pid finishes...${C_NC}"
            caffeinate $flags -w "$pid"
            echo "${C_CYAN}Process $pid finished. Mac can sleep normally now.${C_NC}"
            _keepawake_notify_done "Process $pid has finished!"
            ;;
        -c|--command)
            shift
            if [[ -z "$*" ]]; then
                echo "${C_RED}Error: Please provide a command to run.${C_NC}"
                return 1
            fi
            echo "${C_GREEN}Mac will stay awake while running: ${C_YELLOW}$*${C_NC}"
            echo "------------------------------------------------------------"
            caffeinate $flags "$@"
            echo "------------------------------------------------------------"
            echo "${C_CYAN}Command finished. Mac can sleep normally now.${C_NC}"
            _keepawake_notify_done "Your command has finished running!"
            ;;
        *)
            local input=$1
            local seconds=0
            if [[ $input == *m ]]; then seconds=$((${input%m} * 60))
            elif [[ $input == *h ]]; then seconds=$((${input%h} * 3600))
            elif [[ $input == *s ]]; then seconds=${input%s}
            else seconds=$input; fi

            if ! [[ "$seconds" =~ ^[0-9]+$ ]]; then
                echo "${C_RED}Invalid format.${C_NC} Use a time (30m), -p <PID>, or -c <cmd>."
                return 1
            fi

            echo "${C_GREEN}Mac will stay awake for $input. Press Ctrl+C to cancel.${C_NC}"
            caffeinate $flags -t "$seconds"
            echo "${C_CYAN}Timer finished. Mac can sleep normally now.${C_NC}"
            _keepawake_notify_done "Your $input keepawake timer has finished!"
            ;;
    esac
}

weather() {
    if [[ "$1" == "help" || "$1" == "-h" ]]; then
        echo "${C_CYAN}weather${C_NC}: Terminal weather and forecast."
        echo "Usage: ${C_YELLOW}weather [options] [location]${C_NC}"
        echo ""
        echo "Options:"
        echo "  ${C_YELLOW}-s, --short${C_NC}    Single-line compact format (Temp & Condition)"
        echo "  ${C_YELLOW}-o, --oneline${C_NC}  Rich single-line format (Temp, Wind, Humidity)"
        echo "  ${C_YELLOW}-f, --forecast${C_NC} Detailed visual graph forecast"
        echo "  ${C_YELLOW}-m, --moon${C_NC}     Show current moon phase"
        echo ""
        echo "Examples:"
        echo "  weather London          (Default 3-day text forecast)"
        echo "  weather -o New York     (One-line rich weather)"
        echo "  weather -f              (Detailed forecast for your current IP)"
        return 0
    fi

    local format=""
    local args=()

    for arg in "$@"; do
        case "$arg" in
            -s|--short) format="?format=3" ;;
            -o|--oneline) format="?format=4" ;;
            -f|--forecast) format="?format=v2" ;;
            -m|--moon) format="?Moon" ;;
            -*)
                echo "${C_RED}Unknown option: $arg${C_NC}"
                echo "Run ${C_YELLOW}weather -h${C_NC} for usage."
                return 1
                ;;
            *) args+=("$arg") ;;
        esac
    done

    local loc="${args[*]}"
    loc="${loc// /+}"

    echo "${C_CYAN}Fetching weather data...${C_NC}"
    curl -s "https://wttr.in/${loc}${format}"
}

# ── vi / zle key bindings ─────────────────────────────────────────────────────
bindkey -v
bindkey -M vicmd '?' history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
export KEYTIMEOUT=1

# ── Load ~/.zprofile for non-login shells (login shells already sourced it) ───
# Terminal.app and iTerm2 start login shells, so this is a no-op there.
# VSCode integrated terminal and tmux panes use non-login shells, so they need it.
[[ -o login ]] || { [[ -e ~/.zprofile ]] && source ~/.zprofile; }

# ── Tmux autostart ────────────────────────────────────────────────────────────
# Policy:
#   .zshrc owns the default tmux layout.
#   tmux-continuum auto-restore must stay OFF in ~/.tmux.conf.
#
# Behavior:
#   - If already inside tmux: do nothing.
#   - If inside a Herdr pane: do nothing (see below).
#   - If no real TTY is available: exit cleanly.
#   - If ${USER}-tmux already exists: attach to it.
#   - Otherwise: create a fresh deterministic 6-window layout and attach.
#
# Important:
#   Do NOT call `tmux start-server` here. Starting the server early can trigger
#   plugin startup hooks before this guard logic runs.
#
# Herdr guard (required — see https://herdr.dev/docs/agents/#vms-and-sandbox-wrappers):
#   Window 7 launches herdr via ~/.herdr-start.sh. On a brand-new machine with
#   no session.json, Herdr's first default pane is a blank login shell with
#   $TMUX unset (a fresh pane PTY is not itself a tmux pane), so without this
#   check that pane's .zshrc would re-run this whole autostart block, spawning
#   its own window 7 -> another herdr -> another blank pane -> recursively
#   forever. $HERDR_ENV=1 is set on every process Herdr spawns in a pane, so
#   checking it (independent of $TMUX) blocks the recursion at its source.
_TMUX_SESSION="${USER}-tmux"
if [[ -z "${TMUX:-}" ]] && [[ "${TERM:-}" != screen* ]] && [[ "${HERDR_ENV:-}" != "1" ]]; then
  if [[ ! -t 0 ]]; then
    exit 0
  fi
  if tmux has-session -t "${_TMUX_SESSION}" 2>/dev/null; then
    exec tmux attach-session -t "${_TMUX_SESSION}"
  fi
  tmux new-session -d -s "${_TMUX_SESSION}" -n '~/Desktop' -c "$HOME/Desktop"
  tmux send-keys -t "${_TMUX_SESSION}:1" 'clear' Enter
  tmux new-window -t "${_TMUX_SESSION}:2" -n '2: macports' -c "$HOME"
  tmux send-keys -t "${_TMUX_SESSION}:2" 'source ~/.profile.macports 2>/dev/null; cd /opt/local 2>/dev/null || cd ~; clear' Enter
  tmux new-window -t "${_TMUX_SESSION}:3" -n '3: homebrew' -c "$HOME"
  tmux send-keys -t "${_TMUX_SESSION}:3" 'source ~/.profile.homebrew 2>/dev/null; cd ~/PACKAGEMGMT/Homebrew 2>/dev/null || cd ~; clear' Enter
  tmux new-window -t "${_TMUX_SESSION}:4" -n '4: nix' -c "$HOME/.config/nix-darwin"
  tmux send-keys -t "${_TMUX_SESSION}:4" 'clear' Enter
  tmux new-window -t "${_TMUX_SESSION}:5" -n '5: ~' -c "$HOME"
  tmux send-keys -t "${_TMUX_SESSION}:5" 'clear' Enter
  tmux new-window -t "${_TMUX_SESSION}:6" -n '6: ~' -c "$HOME"
  tmux send-keys -t "${_TMUX_SESSION}:6" 'clear' Enter
  tmux new-window -t "${_TMUX_SESSION}:7" -n '7: herdr' -c "$HOME"
  tmux send-keys -t "${_TMUX_SESSION}:7" '~/.herdr-start.sh' Enter
  tmux select-window -t "${_TMUX_SESSION}:1"
  exec tmux attach-session -t "${_TMUX_SESSION}"
fi
unset _TMUX_SESSION

# ── zoxide (smarter cd) ───────────────────────────────────────────────────────
# `z <fuzzy>` to jump directories, `zi` for interactive fzf selection.
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd z)"
fi

# ── atuin (shell history on steroids) ────────────────────────────────────────
# Ctrl-R opens a full-context fuzzy history search with timestamps.
# Run `atuin login` to sync history across machines (optional, free).
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ── Powerlevel10k instant prompt & config ────────────────────────────────────
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
