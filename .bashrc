#------------------------------
# COLORS
#------------------------------
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

#------------------------------
# ENVIRONMENT VARIABLES
#------------------------------

# BASH/SUDO COMPLETION
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi
complete -cf sudo

# SET PATH
#export PATH=$PATH:/opt/cxoffice/bin

# MISC OPTIONS
export OOO_FORCE_DESKTOP=gnome
export EDITOR=vi
export BROWSER=opera
export CVSROOT=":ext:dgriffiths@aur.archlinux.org:/srv/cvs/community"
export CVS_RSH=ssh
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
set -o noclobber
stty -ctlecho

eval `ssh-agent`
keychain -Q -q $HOME/.ssh/id_rsa
[[ -f $HOME/.keychain/$HOSTNAME-sh ]] && source $HOME/.keychain/$HOSTNAME-sh

# PROMPT
if [ `id -un` != root ]; then
	PS1="[${GR}\u@\h${BL} \W${NONE}]$ "
else
	PS1="[${RD}\u@\h${BL} \W${NONE}]# "
fi

#------------------------------
# ALIASES
#------------------------------
alias pacman='sudo pacman-color'
alias ls='ls --color=auto -h'
alias back='cd $OLDPWD'
alias grep='grep -n --color=auto'
alias chkpkg='namcap PKGBUILD'
alias abssearch='ls -R /var/abs/ | grep'
alias build='cd ~/Build'
alias tuxsay='cowsay -f tux `fortune -a`'

#------------------------------
# FUNCTIONS
#------------------------------
function calc() { echo "$*" | bc; }
function calc2() { bc <<<"$@"; }
function extract() {
	if [ -f $1 ] ; then
		case $1 in
			*.exe)		installexplorer x $1	;;
			*.tar.bz2)	tar xjvf $1		;;
			*.tar.bz)	tar xjvf $1		;;
			*.tar.gz)	tar xvzf $1		;;
			*.bz2)		bunzip2 $1		;;
			*.rar)		rar x $1		;;
			*.gz)		gunzip $1		;;
			*.tar)		tar xvf $1		;;
			*.zip)		unzip $1		;;
			*.Z)		uncompress $1		;;
			*)		echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}


