### COLORS {{{

NONE="\[\033[0m\]"
BK="\[\033[0;30m\]" #Black
EBK="\[\033[1;30m\]"
RD="\[\033[0;31m\]" #Red
ERD="\[\033[1;31m\]"
GR="\[\033[0;32m\]" #Green
EGR="\[\033[1;32m\]"
YW="\[\033[0;33m\]" #Yellow
EYW="\[\033[1;33m\]"
BL="\[\033[0;34m\]" #Blue
EBL="\[\033[1;34m\]"
MG="\[\033[0;35m\]" #Magenta
EMG="\[\033[1;35m\]"
CY="\[\033[0;36m\]" #Cyan
ECY="\[\033[1;36m\]"
WH="\[\033[0;37m\]" #White
EWH="\[\033[1;37m\]"

### COLORS }}} 

### ENVIRONMENT VARIABLES {{{

# BASH/SUDO COMPLETION
if [[ -f /etc/bash_completion ]]; then
	. /etc/bash_completion
	which sudo &>/dev/null && complete -cf sudo
fi

# BASH 4 HAS ./** SUPPORT
[[ ${BASH_VERSINFO[0]} -ge 4 ]] && shopt -s globstar

# SET PATH
[[ -d $HOME/.bin ]] && export PATH=$HOME/.bin:$PATH
export PATH=/opt/lampp/bin:$PATH

# MAKE LESS MORE FRIENDLY
[ -x /usr/local/bin/lesspipe.sh ] && eval "$(lesspipe)"

# MISC OPTIONS
eval `dircolors -b`
[[ -z "$SSH_TTY" ]] && export BROWSER=firefox || export BROWSER=lynx
export EDITOR=vim
export HISTCONTROL=ignoredups
export HISTSIZE=5000
export HISTFILESIZE=1000
export HISTIGNORE='ls:pwd:exit:clear'
export OOO_FORCE_DESKTOP=gnome
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/gtk-2.0/modules/
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
set -o noclobber
[[ -t 0 ]] && stty -ctlecho

# SETUP SSH-AGENT/KEYCHAIN
if [[ -f $HOME/.ssh/id_rsa ]]; then
        eval `ssh-agent`
	which keychain &>/dev/null
	if [[ $? == '0' ]]; then
	        keychain -Q -q $HOME/.ssh/id_rsa
        	[[ -f $HOME/.keychain/$HOSTNAME-sh ]] && source $HOME/.keychain/$HOSTNAME-sh
	fi
fi

# SETUP GIT USERNAME/EMAIL
which git &>/dev/null
if [[ $? == '0' ]]; then
	git config --global user.name "Ghost1227"
	git config --global user.email "dgriffiths@section214.com"
fi

# SETUP BZR USERNAME/EMAIL
which bzr &>/dev/null
if [[ $? == '0' ]]; then
    bzr whoami "Daniel J Griffiths <dgriffiths@section214.com>"
    bzr launchpad-login dgriffiths
fi

# PROMPT
if [[ `id -un` != root ]]; then
    PS1="[${GR}\u@\h${BL} \W${GR}\$(parse_git_branch)\$(git_dirty_flag)${NONE}]$ "
else
    PS1="[${RD}\u@\h${BL} \W${GR}\$(parse_git_branch)\$(git_dirty_flag)${NONE}]# "
fi

# SET TERMNAME
if [[ "$TERM" == 'rxvt-256color' ]] || [[ "$TERM" == 'xterm' ]]; then
        export TERM=xterm
else
        export TERM=linux
fi

### ENVIRONMENT VARIABLES }}}

### ALIASES {{{

alias back='cd $OLDPWD'
alias grep='grep -n --color=auto'
alias hostip='echo `wget -q -O - http://www.whatismyip.org`'
alias ls='ls --group-directories-first --color=auto -h'
alias psearch='ps aux | grep'
alias reload='source ~/.bashrc'
alias vi='vim'
alias sudo='sudo '
alias ssh='ssh -A'
alias phpunit='/opt/lampp/bin/phpunit'
alias php='/opt/lampp/bin/php'

which colortail &>/dev/null && alias tail='colortail -q -k /etc/colortail/conf.messages'
which xrandr &>/dev/null && alias fixres='xrandr --size 1280x1024'

# SETUP HANDLER FOR XCLIP
which xclip &>/dev/null
if [[ $? == '0' ]]; then
    alias xcopy='xclip -sel clip'
fi

git_dirty_flag() {
    git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) print "*"}'
}

parse_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

perfcheck() {
    if [[ -z ${1} ]]; then
        echo "perfcheck <url>"
        return
    fi

    curl -o /dev/null -w 'Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: ${time_total} \n' -s ${1}
}

rsed() {
	if [[ -z ${1} ]] || [[ -z ${2} ]]; then
		echo "rsed <find> <replace>"
		return
	fi

	if [[ -z ${3} ]]; then
		loc='*'
	else
		loc="${3}"
	fi

	for i in $(grep -R "${1}" ${loc} | cut -d ':' -f 1); do
		sed -i "s|${1}|${2}|g" ${i};
	done
}

rwc() {
    if [[ -z ${1} ]]; then
        echo "rwc <path>"
        return
    fi

    total=`find ${1} -type -f -exec wc -l {} \; | awk '{total += $1} END{print total}'`

    echo "Total lines: $total"
}

vercmp() {
	if [[ -z ${1} ]] || [[ -z ${2} ]]; then
		echo "vercmp <oldpath> <newpath>"
		return
	fi

	for i in $(ls ${2}); do
		if [[ "$(diff ${1}/${i} ${2}/${i})" != "" ]]; then
			if [[ ! -d ${1}/${i} ]]; then
				vimdiff ${1}/${i} ${2}/${i};
			fi
		fi
	done
}

lc() {
	unset y;
	for x in $(find . -type f); do
		w=$(wc -l $x | cut -d ' ' -f 1);
		y=$y+$w;
	done;
	echo 0$y | bc;
}

wpdeploy() {
    if [[ -z ${1} ]]; then
        echo "wpdeploy <user> <group>"
        return
    fi

    FEYW="\033[1;33m"
    FEWH="\033[1;37m"
    FEBL="\033[1;34m"
    FNONE="\033[0m"

    USER=${1};

    if [[ -z ${2} ]]; then
        GROUP=${USER};
    else
        GROUP=${2};
    fi

    echo -e "${FEYW}:: ${FEWH}Downloading WordPress...${FNONE}";
    curl --progress-bar -o latest.tar.gz http://wordpress.org/latest.tar.gz;

    echo -e "${FEYW}:: ${FEWH}Extracting WordPress...${FNONE}";
    tar -xf latest.tar.gz;
    mv wordpress/* .;

    echo -e "${FEYW}:: ${FEWH}Setting permissions...${FNONE}";
    chown -R ${USER}:${GROUP} *;

    echo -e "${FEYW}:: ${FEWH}Cleaning up...${FNONE}";
    rm -R wordpress latest.tar.gz;

    echo -e "${FEBL}:: ${FEWH}Done!${FNONE}";
}

### ALIASES }}}

### DEBIAN SPECIFIC {{{

if which apt-get &>/dev/null; then
	alias apt-get='sudo apt-get'

    # SETUP UBUNTU PACKAGING TOOLS
    export DEBFULLNAME="Daniel J Griffiths"
    export DEBEMAIL="dgriffiths@section214.com"
fi

### DEBIAN SPECIFIC }}}
