export TERM="xterm-256color"
# Created by newuser for 5.1.1
source /Users/r1pp3r/PACKAGEMGMT/Homebrew/share/antigen/antigen.zsh 

export ZPLUG_HOME=/Users/r1pp3r/PACKAGEMGMT/Homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh
# zplug "woefe/vi-mode.zsh"

# Customise the Powerlevel9k prompts
# LEFT_PROMPT
# ===========================================================
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon 
    custom_python
    host
    user
    time     
    newline 
    dir_joined 
    status
)

# os_icon custom
POWERLEVEL9K_OS_ICON_BACKGROUND='none'
POWERLEVEL9K_OS_ICON_FOREGROUND='003'

# status
POWERLEVEL9K_STATUS_VERBOSE=true

POWERLEVEL9K_CUSTOM_PYTHON="echo -n '\uf81f' Python"

# battery
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=50
POWERLEVEL9K_BATTERY_VERBOSE=true

# dir
POWERLEVEL9K_SHORTEN_DELIMITER=''
POWERLEVEL9K_SHORTEN_DIR_LENGTH=7
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_first_and_last'

# vi-mode
POWERLEVEL9K_VI_INSERT_MODE_STRING="INSERT"
POWERLEVEL9K_VI_COMMAND_MODE_STRING="NORMAL"	

# RIGHT_PROMP
# ===========================================================
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    load
    ram
    battery 
    background_jobs 
    history
    ssh 
    anaconda 
    vcs    
)


# background_jobs
POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true

# 
POWERLEVEL9K_DIR_ETC_BACKGROUND='none'
POWERLEVEL9K_DIR_ETC_FOREGROUND='003'
POWERLEVEL9K_DIR_HOME_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_FOREGROUND='003'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='none'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='003'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='003'


# vcs
POWERLEVEL9K_SHOW_CHANGESET=true
POWERLEVEL9K_CHANGESET_HASH_LENGTH=6

POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-remotebranch git-tagname)

POWERLEVEL9K_MODE='nerdfont-complete'

# Load the oh-my-zsh's library.
antigen bundle robbyrussell/oh-my-zsh lib/

antigen use oh-my-zsh
# antigen use prezto

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle command-not-found
antigen bundle cp
antigen bundle docker
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle autojump
antigen bundle brew
antigen bundle brew-cask
antigen bundle macports
antigen bundle common-aliases
antigen bundle compleat
antigen bundle git-extras
antigen bundle git-flow
antigen bundle npm
antigen bundle macos
antigen bundle python
antigen bundle terminalapp	
antigen bundle themes
antigen bundle screen
antigen bundle vagrant
antigen bundle vi-mode
antigen bundle web-search
antigen bundle z
#antigen bundle tmux
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh
antigen bundle tarruda/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle git@github.com:spwhitt/nix-zsh-completions.git

# Load the theme.
# antigen bundle nojhan/liquidprompt 
antigen bundle oskarkrawczyk/honukai-iterm-zsh

#antigen theme gnzh
#antigen theme oskarkrawczyk/honukai-iterm-zsh honukai
# antigen theme bhilburn/powerlevel9k powerlevel9k
antigen theme romkatv/powerlevel10k
# antigen theme denysdovhan/spaceship-prompt

# Tell antigen that you're done.
antigen apply

# Setup zsh-autosuggestions
#source /Users/r1pp3r/.zsh-autosuggestions/autosuggestions.zsh

# SetUp GoLang ENV
export GOROOT=`/opt/local/bin/go env GOROOT`
export GOPATH=~/Documents/home_shroder/GoWorkspace

## NVM 
export NVM_DIR="$HOME/.nvm"
[ -s "/Users/r1pp3r/PACKAGEMGMT/Homebrew/opt/nvm/nvm.sh" ] && . "/Users/r1pp3r/PACKAGEMGMT/Homebrew/opt/nvm/nvm.sh"  # This loads nvm
#[ -s "/Users/r1pp3r/PACKAGEMGMT/Homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/Users/r1pp3r/PACKAGEMGMT/Homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

## RUST
export RUSTUP_HOME=$HOME/.rustup
export CARGO_HOME=$HOME/.cargo
# export PATH="$HOME/.cargo/bin:$PATH"
# --> moved to .profile.homebrew


## MOJO
MODULAR_HOME=~/.modular
# PATH=$PATH:$MODULAR_HOME 
# --> Moved to .profile.homebrew


#===============================================================
#
# ALIASES AND FUNCTIONS
#
# Many functions were taken (almost) straight from the bash-2.04
# examples.
#
#==============================================================

# Run Headless Aquaemacs in Debug Mode
alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs -nw"
alias emacs-dbg="/Applications/Emacs.app/Contents/MacOS/Emacs -nw --debug-init"

# Intego Tools
alias vbscanner='/Library/Intego/virusbarrier.bundle/Contents/MacOS/vbscanner'

# LESS
alias less='less -FSRXc'                    # Preferred 'less' implementation


# --- HIBERNATE ---
alias hibernateon="sudo pmset -a hibernatemode 3"
alias hibernateoff="sudo pmset -a hibernatemode 0"
alias switch='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

#-------------------
# Personnal Aliases
#-------------------

alias rm='rm -iv'
alias cp='cp -ivp'
alias mv='mv -iv'
alias mkdir='mkdir -vvv'
alias chmod='chmod -vvv'
alias chown='chown -vvv'


# Alias's to sms shares
alias mount-rgtamde='mount -t smbfs //r1pp3r@intranet.sad.ct.siemens.de/rgtamde ~/mnts/rgtamde'
alias mount-r1pp3r='mount -t smbfs //r1pp3r@defthw990iasto.ww002.siemens.net/r1pp3r$ ~/mnts/r1pp3r'
alias mount-ssi='mount -t smbfs //r1pp3r@intranet.sad.ct.siemens.de/ssi ~/mnts/ssi'
alias mount-sad='mount -t smbfs //r1pp3r@intranet.sad.ct.siemens.de/sad ~/mnts/sad'
alias umount_smb_shares='umount ~/mnts/r1pp3r ~/mnts/ssi ~/mnts/sad ~/mnts/rgtamde'

# Alias's to modified commands
alias ps='ps ax'
alias home='cd ~'
alias pg='ps -aux | grep'  #requires an argument
alias un='tar -zxvf'
alias mountedinfo='df -h'
alias openports='netstat -nape --inet'
alias ns='netstat -alnp --protocol=inet | grep -v CLOSE_WAIT | cut -c-6,21-94 | tail +2'
alias du1='du -h --max-depth=1'
alias da='date "+%Y-%m-%d %A    %T %Z"'

# -> Prevents accidentally clobbering files.
alias h='fc -il 1'
alias j='jobs -l'
alias ..='cd ..'
alias ...='cd ../../'                       # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels
alias path='echo -e ${PATH//:/\\n}'
alias vi='vim'
alias du='du -h'
alias df='df -kh'
alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder

# diverse stuf
#--------------------------------------------------------------------------------------------------------------------
alias c='clear'
alias mi='minicom -m'
alias ping='ping -R -c1 -s512'
alias wget='wget -c -r'

# The 'ls' family (this assumes you use the GNU ls)
alias l='ls -leaFG'
alias lg='ls -laFG | grep'
alias ls='ls -hFGe' # add colors for filetype recognition
alias lx='ls -lXBG' # sort by extension
alias lk='ls -lSrG' # sort by size
alias la='ls -AlG'  # show hidden files
# alias lr='ls -lRG'    # recursice ls
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias lt='ls -ltrG' # sort by date
alias lm='ls -alG |more'    # pipe through 'more'
alias tree='tree -Cs'   # nice alternative to 'ls'
alias bcd='builtin cd'
alias brm='/bin/rm -vvv'

# Alias chmod commands
alias mx='chmod a+x'
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'

# Alias for lynx web browser
alias bbc='lynx -term=vt100 http://news.bbc.co.uk/text_only.stm'
alias nytimes='lynx -term=vt100 http://nytimes.com'

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
    extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
             esac
         else
             echo "'$1' is not a valid file"
         fi
    }


function rm () {
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then :
    else
      local dst=${path##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(/bin/date +%H-%M-%S)
      done
      /bin/mv -vvv "$path" ~/.Trash/"$dst"
    fi
  done
}

# A new version of "cd" which
# prints the directory after cd'ing
cd() {
builtin cd $1
pwd
}

#   memHogsTop, memHogsPs:  Find memory hogs
#   -----------------------------------------------------
    alias memHogsTop='top -l 1 -o rsize | head -20'
    alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#   cpuHogs:  Find CPU hogs
#   -----------------------------------------------------
    alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#   topForever:  Continual 'top' listing (every 10 seconds)
#   -----------------------------------------------------
    alias topForever='top -l 9999999 -s 10 -o cpu'

#   ttop:  Recommended 'top' invocation to minimize resources
#   ------------------------------------------------------------
#       Taken from this macosxhints article
#       http://www.macosxhints.com/article.php?story=20060816123853639
#   ------------------------------------------------------------
    alias ttop="top -R -F -s 10 -o rsize"

#   my_ps: List processes owned by my user:
#   ------------------------------------------------------------
    my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }

#   ---------------------------
#   6.  NETWORKING
#   ---------------------------

alias myip='curl ip.appspot.com'                    # myip:         Public facing IP Address
alias netCons='lsof -i'                             # netCons:      Show all open TCP/IP sockets
alias flushDNS='dscacheutil -flushcache'            # flushDNS:     Flush out the DNS Cache
alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:        Display open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:       Display only open UDP sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:       Display only open TCP sockets
alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:      Get info on connections for en0
alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:      Get info on connections for en1
alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:    All listening connections
alias showBlocked='sudo ipfw list'                  # showBlocked:  All ipfw rules inc/ blocked IPs

#   ---------------------------------------
#   7.  SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------

alias mountReadWrite='/sbin/mount -uw /'    # mountReadWrite:   For use when booted into single-user

#   cleanupDS:  Recursively delete .DS_Store files
#   -------------------------------------------------------------------
    alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

#   finderShowHidden:   Show hidden files in Finder
#   finderHideHidden:   Hide hidden files in Finder
#   -------------------------------------------------------------------
    alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
    alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'

#   cleanupLS:  Clean up LaunchServices to remove duplicates in the "Open With" menu
#   -----------------------------------------------------------------------------------
    alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

#    screensaverDesktop: Run a screensaver on the Desktop
#   -----------------------------------------------------------------------------------
    alias screensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'


#   ---------------------------
#   8.  PACKAGE MANAGERS
#   ---------------------------
alias port='port -v'
alias fink='fink -v'
#alias brew='brew -v'


    # Change directory to the current Finder directory
cdf() {
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
    if [ "$target" != "" ]; then
        cd "$target"; pwd
    else
        echo 'No Finder window found' >&2
    fi
}

# Get colors in manual pages
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

# Misc utilities:

function repeat()       # repeat n times command
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

# Visual Studio Code Editor
#code () {
#    if [[ $# = 0 ]]
#    then
#        open -a "Visual Studio Code"
#    else
#        [[ $1 = /* ]] && F="$1" || F="$PWD/${1#./}"
#        open -a "Visual Studio Code" --args "$F"
#    fi
#}
#function code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$@"; }


# PROXY Settings
function setproxy() {
    export {http,https,ftp}_proxy='http://r1pp3r:passwd@proxy-emea-fth.inac.siemens.net:84'
}

function unsetproxy() {
    unset {http,https,ftp}_proxy
}

# configure proxy for git while on corporate network
# From https://gist.github.com/garystafford/8196920
function proxy_on(){
   # assumes $USERDOMAIN, $USERNAME, $USERDNSDOMAIN
   # are existing Windows system-level environment variables

   # assumes $PASSWORD, $PROXY_SERVER, $PROXY_PORT
   # are existing Windows current user-level environment variables (your user)

   # environment variables are UPPERCASE even in git bash
   export HTTP_PROXY="http://$USERNAME:$PASSWORD@$PROXY_SERVER:$PROXY_PORT"
   export HTTPS_PROXY=$HTTP_PROXY
   export FTP_PROXY=$HTTP_PROXY
   export SOCKS_PROXY=$HTTP_PROXY

   export NO_PROXY="localhost,127.0.0.1,$USERDNSDOMAIN"

   # Update git and npm to use the proxy
   git config --global http.proxy $HTTP_PROXY
   git config --system http.sslcainfo /bin/curl-ca-bundle.crt
   git config --global http.sslcainfo /bin/curl-ca-bundle.crt
   # npm config set proxy $HTTP_PROXY
   # npm config set https-proxy $HTTP_PROXY
   # npm config set strict-ssl false
   # npm config set registry "http://registry.npmjs.org/"

   # optional for debugging
   export GIT_CURL_VERBOSE=1

   # optional Self Signed SSL certs and
   # internal CA certificate in an corporate environment
   export GIT_SSL_NO_VERIFY=1


   env | grep -e _PROXY -e GIT_ | sort
   # echo -e "\nProxy-related environment variables set."

   # clear
}

# Enable proxy settings immediately
### proxy_on

# Disable proxy settings
function proxy_off(){
   variables=( \
      "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY" "SOCKS_PROXY" \
      "NO_PROXY" "GIT_CURL_VERBOSE" "GIT_SSL_NO_VERIFY" \
   )

   for i in "${variables[@]}"
   do
      unset $i
   done

   env | grep -e _PROXY -e GIT_ | sort
   echo -e "\nProxy-related environment variables removed."
}

####################################################################################
#####
#####  Exports
#####
####################################################################################
# JENV -- moved to .profile.homebrew
#export PATH="$HOME/.jenv/bin:$HOME/bin:$PATH"
#eval "$(~/PACKAGEMGMT/Homebrew/bin/jenv init -)"

export HISTTIMEFORMAT="%d/%m/%y %T "
export SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
export JAVA_HOME=`/usr/libexec/java_home`
export JAVA_PATH="$JAVA_HOME"
export JAVA_BINDIR=$JAVA_HOME/bin/
export JDK_HOME="$JAVA_HOME"
[[ -z $DISPLAY ]] && export DISPLAY=":0.0"

### Che Data ###
export CHE_DATA=/Users/r1pp3r/Documents/CheData

####################################################################################
#####
#####  Load ~/.zprofile
#####
####################################################################################
[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'

# Set key timeout to 1ms for zsh vimode
bindkey -v
bindkey -M vicmd '?' history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# function zle-line-init zle-keymap-select {
#     VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
#     RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$(git_custom_status) $EPS1"
#     zle reset-prompt
# }

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

# Start TMUX Session
# If we are not yet in a screen session
#if [[ $TERM != screen* ]]; then
#  # Start tmux if there is no panicfile and tmux actually exists.
#  [ ! -f /tmp/panic -a -x /opt/local/bin/tmux ] && exec tmux
#fi

# Startship 
#eval "$(starship init zsh)"

# Setup nix
export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh

# Nix Aliases
alias nix-env-search="nix-env -qaP"
alias nix-env-install="nix-env -iA"
alias nix-env-update-all="nix-channel --update nixpkgs && nix-env -u '*'"
alias nix-up="nix-env -u"
alias nix-darwin-re="darwin-rebuild switch"
alias nix-homemanager-re="home-manager switch"
alias nixpkg-self-upgrade="sudo -i sh -c 'nix-channel --update && nix-env -iA nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'"
alias nix-gc="nix-collect-garbage -d"
alias nix-darwin-cfg="code ~/.nixpkgs/darwin-configuration.nix"
alias nix-homemgr-cfg="code ~/.config/nixpkgs/home.nix"
alias nix-shell-with-package='nix-shell -p $1'

#Screen autostart
# if [ $TERM != wy30 ] ; then
#         screen -xRRL
# fi

# Tmux autostart
if [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]]; then
    # Check if the session exists
    tmux has-session -t r1pp3r-tmux 2>/dev/null

    if [ $? != 0 ]; then
        # if no session is started, start a new session
        tmux new-session -d -s r1pp3r-tmux

        # Add your predefined windows here
        tmux rename-window -t r1pp3r-tmux:0 '~/Desktop'
        tmux send-keys -t r1pp3r:0 'cd ~/Desktop; clear' Enter
        
        tmux new-window -t r1pp3r-tmux:1 -n '1: macports'
        tmux send-keys -t r1pp3r-tmux:1 'cd ~; source .profile.macports; cd /opt/local; clear' Enter

        tmux new-window -t r1pp3r-tmux:2 -n '2: homebrew'
        tmux send-keys -t r1pp3r-tmux:2 'cd ~; source .profile.homebrew; cd ~/PACKAGEMGMT/Homebrew; clear' Enter

        tmux new-window -t r1pp3r-tmux:3 -n '3: NixPkg'
        tmux send-keys -t r1pp3r-tmux:3 'cd ~/.nixpkgs; clear' Enter

        tmux new-window -t r1pp3r-tmux:4 -n '4: conda'
        tmux send-keys -t r1pp3r-tmux:4 'cd ~; source ~/.profile.homebrew; cd /Users/r1pp3r/PACKAGEMGMT/Homebrew/Caskroom/miniconda/base/bin/; clear' Enter

        tmux new-window -t r1pp3r-tmux:5 -n '5: RUST'
        tmux send-keys -t r1pp3r-tmux:5 'cd ~/.cargo; clear' Enter

        tmux new-window -t r1pp3r-tmux:6 -n '6: Emacs'
        tmux send-keys -t r1pp3r-tmux:6 'cd ~; source .profile.homebrew; /Applications/Emacs.app/Contents/MacOS/Emacs&; clear' Enter

        tmux new-window -t r1pp3r-tmux:7 -n '7: ~'
        tmux send-keys -t r1pp3r-tmux:7 'cd ~; clear' Enter

        tmux new-window -t r1pp3r-tmux:8 -n '8: diss'
        tmux send-keys -t r1pp3r-tmux:8 'cd /Users/r1pp3r/git-repos/overleaf.com/diss; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:9 -n '9: xcode'
        tmux send-keys -t r1pp3r-tmux:9 'cd /Users/r1pp3r/git-repos/github.com/xcode-playground/cs193p/Memorize; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:10 -n '10: xcode_shared'
        tmux send-keys -t r1pp3r-tmux:10 'cd /Users/r1pp3r/Desktop/workspace_exchange/swift/Vaporµs; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:11 -n '11: py'
        tmux send-keys -t r1pp3r-tmux:11 'cd /Users/r1pp3r/git-repos/github.com/PythonPlayground/Udacity_Python/MemeGenerator; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:12 -n '12: py_shared'
        tmux send-keys -t r1pp3r-tmux:12 'cd /Users/r1pp3r/Desktop/workspace_exchange/python/uwb-simulator; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:13 -n '13: rst'
        tmux send-keys -t r1pp3r-tmux:13 'cd /Users/r1pp3r/git-repos/github.com/rust-playground/DungeonCrawlerGame; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:14 -n '14: rst_shared'
        tmux send-keys -t r1pp3r-tmux:14 'cd /Users/r1pp3r/Desktop/workspace_exchange/rust; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:15 -n '15: jvm'
        tmux send-keys -t r1pp3r-tmux:15 'cd /Users/r1pp3r/git-repos/github.com/JavaWorkspace/KotKa; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:16 -n '16: jvm_shared'
        tmux send-keys -t r1pp3r-tmux:16 'cd /Users/r1pp3r/Desktop/workspace_exchange/jvm/; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:17 -n '17: .NET'
        tmux send-keys -t r1pp3r-tmux:17 'cd /Users/r1pp3r/git-repos/github.com/dotNetPlayground/AskGPT; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:18 -n '18: .NET_shared'
        tmux send-keys -t r1pp3r-tmux:18 'cd /Users/r1pp3r/Desktop/workspace_exchange/dotNet/µServices/InventorySystem; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:19 -n '19: cpp'
        tmux send-keys -t r1pp3r-tmux:19 'cd /Users/r1pp3r/git-repos/github.com/CPPPlayground/RoutePlanning/Route_Planning_Playground; source ~/.profile.nix; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:20 -n '20: cpp_shared'
        tmux send-keys -t r1pp3r-tmux:20 'cd /Users/r1pp3r/Desktop/workspace_exchange/cpp/udacity_nd213/AStarDemo; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:21 -n '21: DevEnv'
        tmux send-keys -t r1pp3r-tmux:21 'cd /Users/r1pp3r/git-repos/github.com/DevEnv; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:22 -n '22: MFA'
        tmux send-keys -t r1pp3r-tmux:22 'cd /Users/r1pp3r/git-repos/code.siemens.com/office-platform/infrastructure/scripts/cluster_setup/aws_mfa_utils; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:23 -n '23: OP'
        tmux send-keys -t r1pp3r-tmux:23 'cd /Users/r1pp3r/git-repos/code.siemens.com/office-platform/csx-core-system/prototypes/sut-setup/charts/csx-sut; source ~/.profile.nix; clear' Enter
        
        tmux new-window -t r1pp3r-tmux:24 -n '24: exercism'
        tmux send-keys -t r1pp3r-tmux:24 'cd /Users/r1pp3r/git-repos/github.com/exercism; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:25 -n '25: VTC'
        tmux send-keys -t r1pp3r-tmux:25 'cd /Users/r1pp3r/Desktop/workspace_exchange/MyApps/Virtual\ Time\ Capsule; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:26 -n '26: AIPlayground'
        tmux send-keys -t r1pp3r-tmux:26 'cd /Users/r1pp3r/git-repos/github.com/AIPlayground; source ~/.profile.nix; clear' Enter

        tmux new-window -t r1pp3r-tmux:27 -n '27: AIPlayground'
        tmux send-keys -t r1pp3r-tmux:27 'cd /Users/r1pp3r/git-repos/github.com/AIPlayground; source ~/.profile.nix; clear' Enter
      # Add more windows as per your need
    fi

    # Finally attach to the session
    tmux attach-session -t r1pp3r-tmux
fi

