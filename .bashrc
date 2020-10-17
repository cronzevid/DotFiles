export VISUAL="vim"
export PROMPT_COMMAND=prompt
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r;"

#export PATH="$HOME/.jenv/bin:$PATH"
#eval "$(jenv init -)"
export GOPATH="$HOME/go"

HISTFILESIZE=10000000
HISTSIZE=10000000
SHELL_SESSION_HISTORY=0

if [[ 'cool-retro-term' == `ps -p \`ps -p $$ -o ppid=\` o args=` ]] && [[ $TERM != 'screen' ]]; then
  tmux a -t retro || tmux new -s retro;
fi

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

##Colors:
NC="\[\033[00m\]"
BLUE="\[\033[1;34m\]"
YELLOW="\[\033[1;33m\]"
RED="\[\033[1;31m\]"
GREEN="\[\033[1;32m\]"

function prompt() {
  EXIT=${?}

  PS1="${debian_chroot:+($debian_chroot)}"

  if [ "`id -u`" -eq 0 ]; then
    PS1+="$RED"
  else
    PS1+="$GREEN"
  fi

  PS1+="\u@\h$NC:$BLUE\w ["

  if [[ ${EXIT} == 0 ]]; then
    PS1+="$GREEN"
  else
    PS1+="$RED"
  fi

  PS1+="${EXIT}$BLUE] "

  if [ "`id -u`" -eq 0 ]; then
    PS1+="#"
  else
    PS1+="\$"
  fi
  PS1+="$NC "
}

alias ll='lsd $LS_OPTIONS -lah'
alias grep='grep $GREP_OPTIONS --color'
alias grin="grep -rniI $1"
alias rm='rm -rf'
alias tailf="tail -f"

alias h='sudo vim /etc/hosts'
alias r='sudo vim /etc/resolv.conf'
alias rand_wlan='sudo macchanger -r wlan0'
alias rand_eth='sudo macchanger -r eth0'
alias googler='googler -x --colorize always  --unfilter --np -n 50'

alias macchanger='openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//" | xargs sudo ifconfig en0 ether'
alias transfer='function func1(){ curl --upload-file $1 https://transfer.sh/$1; printf "\n"; };func1'

clean_var () {
    if [[ -z $1 ]]; then
        echo 'No server to clean';
        echo 'Usage: clean_var <server_name>';
        return 1;
    else
	ssh -tt -i /home/user/.ssh/special.id.rsa user@remote.host -C "clean_var $1";
    fi
}


g () {
    if [[ -z $1 ]]; then
        echo 'No server to go';
        echo 'Usage: go <server_name>';
        return 1;
    else
	ssh -tt -i /home/user/.ssh/special.id.rsa user@remote.host -C "go $1";
    fi
}

scp_tunnel () {
    if [[ -z $1 ]]; then
        echo 'No server to go';
        echo 'Usage: <remote_server> <file_path> <local_file_path>';
        return 1;
    elif [[ -z $2 ]]; then
        echo 'No files to transfer';
        echo 'Usage: <remote_server> <file_path> <local_file_path>';
        return 1;
    elif [[ -z $3 ]]; then
        echo 'No local file to recieve';
        echo 'Usage: <remote_server> <file_path> <local_file_path>';
        return 1;
    else
	ssh -o StrictHostKeyChecking=no user@remote.host "ssh -o StrictHostKeyChecking=no sudo_user@$1 -i /home/user/sudo_user.id_rsa \"sudo tar cj $2\" " | pv - > $3
    fi
}

tmuxinate () {
    if [[ -z $1 ]]; then
        echo 'No servers to go';
        echo 'Usage: tmuxinate <server_list>';
        return 1;
    elif  [[ "$#" -le 1 ]]; then
        echo 'Need more than 1 server';
        echo 'Usage: tmuxinate <server_list>';
        return 1;
    else
	count=0
	###Initiate
#       tmux new-session 'ssh -q user@remote.host' \; split-window -h 'ssh -q user@remote.host' \; split-window -v \; setw synchronize-panes \; attach
#        tmux new-session -d -n tmuxinate "ssh -tt -q user@remote.host -C \"go $1\""
	for i in "$@"; do
            if tmux split-window -t tmuxinate -t $count -v "ssh -tt -q user@remote.host -C \"go $i\"" 2>/dev/null; then
	        count=$((count+1))
	    else
	        tmux new-session -d -n tmuxinate "ssh -tt -q user@remote.host -C \"go $i\""
            fi
        #    if [ $count -ne "$#" ]; then
	        ###Interact
	#	if [ $(($count%2)) -eq 0 ]; then
        #            tmux split-window -t tmuxinate -t $count -v "ssh -tt -q user@remote.host -C \"go $i\""
#                    tmux split-window -t tmuxinate -t $count -v "ssh -tt -q user@remote.host -C \"go $i\"" || tmux new-session -d -n tmuxinate "ssh -tt -q user@remote.host -C \"go $i\""
	#	elif [ $(($count%2)) -eq 0 ]; then
        #            tmux split-window -t tmuxinate -t $count -h "ssh -tt -q user@remote.host -C \"go $i\""
#                    tmux split-window -t tmuxinate -t $(($count+1)) -h "ssh -q user@remote.host -C \"go $i\""
#                tmux split-window -t tmuxinate -h 'ssh -q user@remote.host'
#                tmux split-window -t tmuxinate -t 0 -h 'ssh -q user@remote.host'
#                tmux split-window -t tmuxinate -t 1 -v 'ssh -q user@remote.host'
        #       fi
	#    fi
	#    count=$((count+1))
	done
        tmux set-window-option  -t tmuxinate  synchronize-panes
        tmux select-layout -t tmuxinate tiled
	tmux bind-key -n C-y setw synchronize-panes off
        tmux attach
    fi
}

know () {
    echo "Updating!";
    for i in /usr/local/share/knowledge_base/*; do
        cd $i;
        git pull;
        cd
    done
    echo "Done!";
    echo "Strings:";
    echo;
    grep -rniI $1 /usr/local/share/knowledge_base
    echo "========================================";
    echo "Files:";
    echo;
    find /usr/local/share/knowledge_base -iname "*$1*" -type f
    echo "========================================";
    echo "Dirs:";
    echo;
    find /usr/local/share/knowledge_base -iname "*$1*" -type d
    echo "========================================";
}

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize
shopt -s expand_aliases

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.tar.xz)    unxz $1 && tar xvf $1 ;;
      *.xz)        unxz $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

macmanufact () {

  if [[ -z $1 ]]; then
    echo 'Usage: macmanufact <macaddress>'
    return 1
  fi

  mac=`echo $1 | sed 's#:#-#g'`
  mac2=`echo $mac | tr -d '-'`

  manufact=`grep -i ${mac:0:8} /etc/aircrack-ng/airodump-ng-oui.txt`

  if [[ -z $manufact ]]; then
      manufact=`grep -i ${mac2:0:6} /usr/share/nmap/nmap-mac-prefixes`
  fi

  echo $manufact
}

check_cert () {
  if [[ -z $1 ]] || [[ -z $2 ]]; then
    echo 'Usage: check_cert <key> <cert>'
    return 1
  fi

  key=$1
  cert=$2

  key_mod=`openssl rsa -noout -modulus -in $key | openssl md5`
  crt_mod=`openssl x509 -noout -modulus -in $cert | openssl md5`

  if [[ $key_mod == $crt_mod ]]; then
    echo 'Key/cert pair valid'
  else
    echo 'Key/cert modulus do not match'
  fi
}

mstrace() {
  if [[ -z $1 ]] || [[ -z $2 ]]; then
    echo 'Usage: mstrace <name/pid> <fd>'
    return 1
  fi

  re='^[0-9]+$'
  if ! [[ $2 =~ $re ]]; then
    echo 'Error: fd is not a number'
    return 1
  fi

  if ! [[ $1 =~ $re ]]; then
    pid=`ps aux --forest | grep -i $1 | grep -v grep | awk '{print $2}' | head -1`
  else
    pid=$1
  fi

  stdbuf -i0 -o0 -e0 strace -ttf -xx -p 25199 -s 9999 -e write 2>&1 | parse_strace $2
}

function ip_drop() {
    if [[ -z $1 ]]; then
        echo "No ip to block";
        echo "Usage: ip_drop <ipv4 adress>";
        return 1;
    elif [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "$1 added to iptables";
        iptables -A INPUT -s $1 -j DROP;
        return 0;
    else
        echo "Invalid input";
        return 1;
    fi
}

function ssh () {
    /usr/bin/ssh -t $@ "tmux attach || tmux new";
}

eval $(thefuck --alias)
