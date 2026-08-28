#!/bin/bash

# Controls the action of an interactive shell on receipt of an EOF character
# as the sole input. If set, the value is the number of consecutive EOF 
# characters which must be typed as the first characters on an input line
# before bash exits. If the variable exists but does not have a numeric
# value, or has no value, the default value is 10. If it does not exist,
# EOF signifies the end of input to the shell.
export IGNOREEOF=1
export TERM=xterm-256color
export HISTSIZE=1000000
export EDITOR=/usr/bin/nvim

alias ..="cd .."
alias ll="ls -lh"
alias sudovim="sudo -E vim"
alias fde="fd | fzf | xargs nvim"

parse_git_branch() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')
    [ ! -z "$branch" ] && printf " "
    echo "$branch "
}

copy_git_branch() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    printf "%s" $branch | wl-copy
}

shorten_cwd() {
    if [ "$PWD" = "$HOME" ]; then echo '~'; else
        echo $(echo "${PWD%/*}" | sed "s;$HOME;~;" | sed -e "s;\(/.\)[^/]*;\1;g")"/${PWD##*/}"
    fi
}

append_ts() {
    $1 | while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line"; done
}

docker-ps-filtered() {
    [ -z "$1" ] && echo "Please provide an image tag/id as argument" && return
    docker ps -a -q --filter ancestor=$1 --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}"
}

docker-rm-filtered() {
    [ -z "$1" ] && echo "Please provide an image tag/id as argument" && return
    docker rm $(docker ps -a -q --filter ancestor=$1)
}

set_ps1() {
    ## Colors?  Used for the prompt.
    #Regular text color
    BLACK='\[\e[0;30m\]'
    #Bold text color
    BBLACK='\[\e[1;30m\]'
    #background color
    RED='\[\e[0;31m\]'
    BRED='\[\e[1;31m\]'
    GREEN='\[\e[0;32m\]'
    BGREEN='\[\e[1;32m\]'
    YELLOW='\[\e[0;33m\]'
    BYELLOW='\[\e[1;33m\]'
    BLUE='\[\e[0;34m\]'
    BBLUE='\[\e[1;34m\]'
    BGBLUE='\[\e[1;34m\]'
    MAGENTA='\[\e[0;35m\]'
    BMAGENTA='\[\e[1;35m\]'
    CYAN='\[\e[0;36m\]'
    BCYAN='\[\e[1;36m\]'
    WHITE='\[\e[0;37m\]'
    BWHITE='\[\e[1;37m\]'
    LRED='\[\e[0;91m\]'
    LBRED='\[\e[1;91m\]'
    LGREEN='\[\e[0;92m\]'
    LBGREEN='\[\e[1;92m\]'
    LYELLOW='\[\e[0;93m\]'
    LBYELLOW='\[\e[1;93m\]'
    LBLUE='\[\e[0;94m\]'
    LBBLUE='\[\e[1;94m\]'
    LPURPLE='\[\e[0;95m\]'
    LBPURPLE='\[\e[1;95m\]'
    LCYAN='\[\e[0;96m\]'
    LBCYAN='\[\e[1;96m\]'
    UNKBLK='\e[4;30m' # Black - Underline
    UNDRED='\e[4;31m' # Red
    UNDGRN='\e[4;32m' # Green
    UNDYLW='\e[4;33m' # Yellow
    UNDBLU='\e[4;34m' # Blue
    UNDPUR='\e[4;35m' # Purple
    UNDCYN='\e[4;36m' # Cyan
    UNDWHT='\e[4;37m' # White
    DF='\[\e[0m\]'

    if [ -n "$YOCTO_DEV" ]; then
        PS1="[${BBLUE}@${BWHITE}\h ${LBLUE}\W${DF}]${LBGREEN}${DF}${PS1_EXTRA}\$ "
    fi
}

kill_from_list() {
    pgrep -a $1 | fzf | awk '{print $1}' | xargs kill
}
