<#
.SYNOPSIS
    Linux Setup Script for configuring development environment
.DESCRIPTION
    This script automates the setup of various development tools including:
    - Shell configuration (bash/zsh)
    - Vim editor setup
    - Git configuration
    - Tmux setup
    - System information display
.NOTES
    Author: Chauncey Yan
    Version: 0.1
    Last Modified: Oct 10 2016
#>

#!/bin/bash
############################################
# Program	: Bash Setup Script
# Author	: Chauncey Yan
# Features	: List the info. of the system. 
#             Prompt to setup shell, vim, 
#             git, and tmux.
# Revision	: 0.1
# Mod date	: Oct 10 2016
# Updates	:
# Issues	:
############################################
# Name      : check system information
# Issues	:
############################################
check_sys (){
    # system report
    echo "################################";
    printf "${GREEN}Checking system configurations...${NC}\n"
    host_name=`uname -n`
    system=`uname -o`
    kernel=`uname -s`
    kernel_release=`uname -r`
    echo "################################";
    echo "Hostname : $host_name";
    echo "System   : $system";
    echo "Kernel   : $kernel";
    echo "Release  : $kernel_release";

    #type uptime >/dev/null 2>&1 || { echo >&2 "No uptime!"; exit 1; }
    #type hostname >/dev/null 2>&1 || { echo >&2 "No hostname!"; exit 1; }
    #uname_return=$(uname -a)
    #system=$(echo $uname_return | awk 'NF>1{print $NF}')
    return
}
############################################
# setup shell bashrc zshrc
# setup .aliases
# setup autpo start
############################################
shell_setup(){
    echo "################################";
    printf "${GREEN}Checking shell configurations...${NC}\n"
    echo "\$SHELL   : $SHELL"
    echo "env check";
    echo "\$PATH check";
    echo "\$HOME check";
    shell=`basename $SHELL`
    file_handler ${shell}rc
    file_handler aliases
    return
}
############################################
# setup vimrc 
# setup vim plugin
# populate vim colors
############################################
vim_setup(){
    echo "################################";
    printf "${GREEN}Checking vim configurations...${NC}\n"
    file_handler 'vimrc'

    mkdir -p $HOME/.vim/colors
    cp -nv $SRC/dotFiles/vim/colors/* $HOME/.vim/colors
    return
}
############################################
# setup git shortcuts, name, email, ssh
############################################
git_setup(){
    echo "################################";
    printf "${GREEN}Checking git configurations...${NC}\n"
    file_handler 'gitconfig'
    return
}
############################################
# setup tmux config
############################################
tmux_setup(){
    echo "################################";
    printf "${GREEN}Checking tmux configurations...${NC}\n"
    file_handler 'tmux.conf'
    return
}
############################################
# setup tmux config
############################################
pushbullet_setup(){
    echo "################################";
    printf "${GREEN}Checking pushbullet configurations...${NC}\n"
    if [ -x $HOME/git/pushbullet-bash/pushbullet ] ;then
        echo "Pushbullet exsits."
    fi
    file_handler 'tmux.conf'
    return
}
############################################
# file handler
# decide if swap or merge or do nothing
############################################
file_handler(){
    echo "################################";
    if [ -f "$HOME/.${1}" ];then
        printf "${RED}Found .${1} in ${HOME}.${NC}\n";
        echo "Type 0 for dont change .${1}."
        echo "Type 1 for swap the files."
        echo "Type 2 for merge two .${1}."
        while true; do
            read sm
            case $sm in
                0 ) echo No change on ${HOME}/.${1}; break;;
                1 ) file_swap $SRC/dotFiles/${1} $HOME/.${1};
                    break;;
                2 ) file_merge $SRC/dotFiles/${1} $HOME/.${1};
                    break;;
                * ) echo "Please answer 0, 1 or 2.";;
            esac
        done
    else
        printf "${YELLOW}Copied .${1} file to $HOME${NC}\n";
        cp $SRC/dotFiles/${1} $HOME/.${1}
    fi
    return
}
############################################
# file merge 
# append new file at the end of the original
# comment out all of same lines
############################################
file_merge(){
    echo "################################";
    cat $1 >> $2; 
    printf "${YELLOW}File merged between${NC}\n"
    echo $1 
    echo $2
    return
}
############################################
# file swap
# backup the original file 
# replace with the new config
############################################
file_swap(){
    echo "################################";
    printf "${YELLOW}File swapped between${NC}\n"
    echo $1 
    echo $2
    last_bak=$2
    while [ -f ${last_bak}.bak ]; do
        last_bak=${last_bak}.bak
    done
    mv $2 ${last_bak}.bak
    cp $1 $2
    printf "${YELLOW}Backup file created at${NC}\n"
    echo ${last_bak}.bak
    return
}
############################################
############################################
# Main		:
# Issues	:
############################################
# check what shell is used
############################################
# Detect current shell
############################################
detect_shell() {
    # Check current shell from $SHELL or $0
    current_shell=$(basename "$SHELL")
    if [ -z "$current_shell" ]; then
        current_shell=$(basename "$0")
    fi

    case "$current_shell" in
        "bash")
            echo "Bash shell detected"
            shell="bash"
            ;;
        "zsh") 
            echo "Zsh shell detected"
            shell="zsh"
            ;;
        "fish")
            echo "Fish shell detected" 
            shell="fish"
            ;;
        *)
            echo "Unknown shell: $current_shell"
            shell="unknown"
            ;;
    esac
    return
}

detect_shell
# Absolute path this script is in
SCRIPTPATH=`readlink -f "$_"`
SRC=`dirname $SCRIPTPATH`
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
printf "${GREEN}Linux Setup Script. Version 0.1.${NC}\n"
# check what system is used
check_sys;
shell_setup;
vim_setup;
git_setup;
tmux_setup;
#source $HOME/.${shell}rc
############################################
# example code
############################################
#if [[ -z $var ]];then # -n for not empty
#	echo var is empty
#fi
#for i in $(seq 1 2 20);do
#	echo number $i
#done
