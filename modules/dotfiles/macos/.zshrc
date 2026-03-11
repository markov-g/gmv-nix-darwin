export TERM="xterm-256color"

# ── Plugin manager (antigen) ──────────────────────────────────────────────────
source ~/PACKAGEMGMT/Homebrew/share/antigen/antigen.zsh

# ── oh-my-zsh via antigen ─────────────────────────────────────────────────────
# Note: p10k theme is configured via ~/.p10k.zsh (run `p10k configure` to regenerate).
# POWERLEVEL9K_* vars are NOT read by powerlevel10k — only p9k reads them.
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
antigen bundle tarruda/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle git@github.com:spwhitt/nix-zsh-completions.git

# Theme
antigen theme romkatv/powerlevel10k

antigen apply

# ── Language / toolchain env ──────────────────────────────────────────────────
# Note: RUSTUP_HOME, CARGO_HOME, PATH for cargo are in .zshenv (always sourced).

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
alias darwin-re="darwin-rebuild switch --flake ~/.config/nix-darwin"
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

# cd with pwd echo
cd() { builtin cd "$1" && pwd; }

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

repeat() {
  local i max=$1; shift
  for ((i=1; i <= max; i++)); do eval "$@"; done
}

ask() {
  echo -n "$@ [y/n] "; read ans
  case "$ans" in y*|Y*) return 0 ;; *) return 1 ;; esac
}

my_ps() { ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command; }

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
_TMUX_SESSION="${USER}-tmux"
if [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]]; then
  if ! tmux has-session -t "${_TMUX_SESSION}" 2>/dev/null; then
    tmux new-session -d -s "${_TMUX_SESSION}"

    tmux rename-window -t "${_TMUX_SESSION}:0" '~/Desktop'
    tmux send-keys -t "${_TMUX_SESSION}:0" 'cd ~/Desktop; clear' Enter

    tmux new-window -t "${_TMUX_SESSION}:1" -n '1: macports'
    tmux send-keys -t "${_TMUX_SESSION}:1" 'cd ~; source .profile.macports; cd /opt/local; clear' Enter

    tmux new-window -t "${_TMUX_SESSION}:2" -n '2: homebrew'
    tmux send-keys -t "${_TMUX_SESSION}:2" 'cd ~; source .profile.homebrew; cd ~/PACKAGEMGMT/Homebrew; clear' Enter

    tmux new-window -t "${_TMUX_SESSION}:3" -n '3: nix'
    tmux send-keys -t "${_TMUX_SESSION}:3" 'cd ~/.config/nix-darwin; clear' Enter

    tmux new-window -t "${_TMUX_SESSION}:4" -n '4: ~'
    tmux send-keys -t "${_TMUX_SESSION}:4" 'cd ~; clear' Enter

    tmux new-window -t "${_TMUX_SESSION}:5" -n '5: ~'
    tmux send-keys -t "${_TMUX_SESSION}:5" 'cd ~; clear' Enter
  fi
  tmux attach-session -t "${_TMUX_SESSION}"
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
