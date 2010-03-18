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
[[ -d /usr/share/perl5/vendor_perl/auto/share/dist/Cope ]] && export PATH=/usr/share/perl5/vendor_perl/auto/share/dist/Cope:$PATH

# MISC OPTIONS
eval `dircolors -b`
[[ -z "$SSH_TTY" ]] && export BROWSER=chromium || export BROWSER=lynx
export CVSROOT=":ext:dgriffiths@aur.archlinux.org:/srv/cvs/community"
export CVS_RSH=ssh
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
        keychain -Q -q $HOME/.ssh/id_rsa
        [[ -f $HOME/.keychain/$HOSTNAME-sh ]] && source $HOME/.keychain/$HOSTNAME-sh
fi

# SETUP GIT USERNAME/EMAIL
which git &>/dev/null
if [[ $? == '0' ]]; then
	git config --global user.name "Ghost1227"
	git config --global user.email "ghost1227@archlinux.us"
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

which colortail &>/dev/null && alias tail='colortail -q -k /etc/colortail/conf.messages'
which xrandr &>/dev/null && alias fixres='xrandr --size 1280x1024'

### ALIASES }}}

### DEBIAN SPECIFIC {{{

if which apt-get &>/dev/null; then
	alias apt-get='sudo apt-get'
fi

### DEBIAN SPECIFIC }}}

### ARCH SPECIFIC {{{

if which pacman &>/dev/null; then
	alias pacman='sudo pacman'
	which clyde &>/dev/null && alias clyde='sudo clyde'

	function aurget() {
        	if [[ -z $1 ]]; then
                	echo -e "aurget requires an argument!"
	                return 1
        	fi

	        if [[ -f $1.tar.gz ]] || [[ -d $1 ]]; then
        	        echo -e "$1 already exists in build directory!"
                	return 1
	        fi

        	wget -q aur.archlinux.org/packages/$1/$1.tar.gz

	        if [[ ! -f $1.tar.gz ]]; then
        	        echo -e "$1 does not exist in AUR!"
                	return 1
	        fi

        	tar -xvf $1.tar.gz
	        rm $1.tar.gz
        	cd $1
	}

	function cpkg() {
		NAME=`echo $1 | sed -e 's|/||'`
	        tar -cf $NAME.tar $NAME
        	gzip $NAME.tar
	        rm -R $NAME
	}

fi

###  ARCH SPECIFIC }}}

### PKGBUILD.com SPECIFIC {{{

if [[ "$HOSTNAME" == "pkgbuild" ]]; then
	alias chrootupdate='sudo chrootupdate'
	alias makechrootpkg='sudo makechrootpkg'

	function pkgcleanup() {
	        if [[ ! -f PKGBUILD ]]; then
                	echo "PKGBUILD not found!"
        	        return 1
	        fi

        	sed -i 's|\$srcdir|\${srcdir}|g' PKGBUILD
	        sed -i 's|\$startdir/src|\${srcdir}|g' PKGBUILD
        	sed -i 's|\${startdir}/src|\${srcdir}|g' PKGBUILD
	        sed -i 's|\$pkgdir|\${pkgdir}|g' PKGBUILD
	        sed -i 's|\$startdir/pkg|\${pkgdir}|g' PKGBUILD
        	sed -i 's|\${startdir}/pkg|\${pkgdir}|g' PKGBUILD
	        sed -i 's|\$pkgname|\${pkgname}|g' PKGBUILD
        	sed -i 's|\$pkgver|\${pkgver}|g' PKGBUILD
	}

	function archco() {
        	PACKAGE=$1
	        if [[ -z $PACKAGE ]]; then
        	        echo "archco requires an argument!"
	                return 1
        	fi
	        if [[ ! -d $HOME/extra/svn-packages ]]; then
        	        mkdir $HOME/extra >/dev/null
	                cd $HOME/extra
                	svn checkout -N svn+ssh://gerolde.archlinux.org/srv/svn-packages
        	fi
	        cd $HOME/extra/svn-packages
        	/usr/bin/archco $PACKAGE
	        cd $PACKAGE/trunk
        	pkgcleanup
	}

	function communityco() {
        	PACKAGE=$1
	        if [[ -z $PACKAGE ]]; then
                	echo "communityco requires an argument!"
        	        return 1
	        fi
        	if [[ ! -d $HOME/community/svn-packages ]]; then
	                mkdir $HOME/community >/dev/null
        	        cd $HOME/community
	                svn checkout -N svn+ssh://aur.archlinux.org/srv/svn-packages
        	fi
	        cd $HOME/community/svn-packages
        	/usr/bin/communityco $PACKAGE
	        cd $PACKAGE/trunk
        	pkgcleanup
	}

fi

### PKGBUILD.com SPECIFIC }}}
