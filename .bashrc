# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

###############################################################################################

# solarized like theme for tty/xterm
if [ "$TERM" = "xterm" ]; then
echo -en "\e]P0073642" #black
echo -en "\e]P8002b36" #brblack
echo -en "\e]P1dc322f" #red
echo -en "\e]P9cb4b16" #brred
echo -en "\e]P2859900" #green
echo -en "\e]PA586e75" #brgreen
echo -en "\e]P3b58900" #yellow
echo -en "\e]PB657b83" #bryellow
echo -en "\e]P4268bd2" #blue
echo -en "\e]PC839496" #brblue
echo -en "\e]P5d33682" #magenta
echo -en "\e]PD6c71c4" #brmagenta
echo -en "\e]P62aa198" #cyan
echo -en "\e]PE93a1a1" #brcyan
echo -en "\e]P7eee8d5" #white
echo -en "\e]PFfdf6e3" #brwhite
clear #for background artifacting
fi

################################################################################################

# ranger stuff
export RANGER_LOAD_DEFAULT_RC=FALSE

# Taken from ranger manual, use ^O to use Ranger for cd

function r {
  tempfile='/tmp/chosendir'
  ranger --choosedir="$tempfile" "${@:-$(pwd)}"
  test -f "$tempfile" &&
  if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
    builtin cd -- "$(cat "$tempfile")"
  fi
  rm -f -- "$tempfile"
}
export -f r

################################################################################################

export VIMRC='~/.vimrc'
export EDITOR='vim'

function _git_prompt() {
    [ "`which git`" = "" ] && exit 0

    local git_status="`git status -unormal 2>&1`"
    local END_COLOR='\e[0m'
    local color_clean="\[\033[38;5;112m\]"
    local color_untracked="\[\033[38;5;196m\]"
    local color_files_to_commit="\[\033[38;5;213m\]"
    local color_not_staged="\[\033[38;5;160m\]"
    local color_files_to_push="\[\033[38;5;75m\]"

    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi=$color_clean
            local branch_status='✓'
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi=$color_untracked
            local branch_status='±'
        elif [[ "$git_status" =~ Changes\ to\ be\ committed ]]; then
            local ansi=$color_files_to_commit
            local branch_status='~'
        elif [[ "$git_status" =~ Changes\ not\ staged\ for\ commit ]]; then
            local ansi=$color_not_staged
            local branch_status='!'
        else
            local ansi=$color_files_to_commit
            local branch_status='^'
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            #test "$branch" != master || branch=' '
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            local branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        echo -n "${ansi} ${branch} ${branch_status}${END_COLOR} | "
    fi
}

function _prompt_command (){
    local user="\[\033[38;5;160m\]\u"
    local host="\[\033[38;5;250m\]@\[\033[38;5;214m\]\h "
    local date="\[\033[38;5;165m\]$(date +'%a %d %b') "
    local timenow="\[\033[38;5;141m\]$(date +'%R') "
    local wdir="\[\033[38;5;34m\]\w "
    local files="\[\033[38;5;112m\]$(ls -1 | wc -l | sed 's: ::g') files "
    local fsize="\[\033[38;5;011m\]$(ls -lah | grep -m1 total | sed 's/total //')b\[\033[0m\]"
    local colend="\[\033[0m\]"
    PS1="\n`_git_prompt`${user}${host}${date}${timenow}${wdir}${files}${fsize}${colend}: \n$ "
}
PROMPT_COMMAND=_prompt_command

################################################################################################

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

export HISTFILESIZE=20000
export HISTSIZE=10000

HISTCONTROL=ignoredups    # ignore duplicates
HISTCONTROL=ignorespace   # ignore cmds with leading space
HISTCONTROL=ignoreboth    # dont add successive cmds

shopt -s checkwinsize
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s extglob

set completion-ignore-case On

################################################################################################

alias mkdir='mkdir -pv'
alias gh='cd ~'
alias meminfo='free -m -l -t'
alias diskspace='du -S | sort -n -r | less'
alias folders='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'

function cd () {
    if [ "$1" != ""  ];then
        if [ "$@" = "-" ];then
            builtin cd - && ls .
        elif [ -d "$@" ];then
            builtin cd "$@" && ls .
        elif [ -f "$@" ];then
            builtin cd "`dirname "$@"`" && ls .
        elif [ ! -d "$1" ];then
            echo "$1 is not a directory."
        fi
    fi
}


##############################################################################################

function my_ps () { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }

