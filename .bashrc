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

# MAKE LESS MORE FRIENDLY
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# MISC OPTIONS
eval `dircolors -b`
[[ -z "$SSH_TTY" ]] && export BROWSER=chromium || export BROWSER=lynx
export EDITOR=vim
export HISTCONTROL=ignoredups
export HISTSIZE=5000
export HISTFILESIZE=1000
export HISTIGNORE='ls:pwd:exit:clear'
export OOO_FORCE_DESKTOP=gnome
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
set -o noclobber
stty -ctlecho

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
	git config --global user.email "dgriffiths@ghost1227.com"
fi

# PROMPT
if [[ `id -un` != root ]]; then
        PS1="[${GR}\u@\h${BL} \W${NONE}]$ "
else
        PS1="[${RD}\u@\h${BL} \W${NONE}]# "
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

which colortail &>/dev/null && alias tail='colortail -q -k /etc/colortail/conf.messages'
which xrandr &>/dev/null && alias fixres='xrandr --size 1280x1024'

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
	
### ALIASES }}}

### DEBIAN SPECIFIC {{{

if which apt-get &>/dev/null; then
	alias apt-get='sudo apt-get'
fi

### DEBIAN SPECIFIC }}}
