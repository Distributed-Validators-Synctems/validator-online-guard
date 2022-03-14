#!/bin/bash
# Copyright (C) 2021 Distributed Validators Synctems -- https://validators.network

# This script comes without warranties of any kind. Use at your own risk.

# The purpose of this script is to guard validator node against appearance of another validator node with same key 
# and to prevent double signing. 
# This may happen if main validator node goes offline because of problems on provider side, and you need to start another one
# but if first validator appears online again it will lead to double signing if seconds validator will not be shut down.

# Supported operation systems: Debian, Ubuntu

# Colors
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m' # No Color

BOLD='\033[1m'
RESET_BOLD='\033[21m'
UNDERLINE='\033[4m'
RESET_UL='\033[24m'

FLOAT_RE='^[0-9]+(\.[0-9]+)?$' 

echo "*********************************************************************"
echo "*                                                                   *"
echo "* Distributed Validators Synctems Validator Online guard automation *"
echo "*                                                                   *"
echo "*********************************************************************"
echo ""
echo -e "${RED}${BOLD}DISCLAIMER${NC}: Use this script at your ${RED}${BOLD}OWN${NC} risk!"
echo ""
echo "Welcome to the DVS Validator Online guard installation script. This script will collect all the data required to run automation."
echo -e "${RED}${BOLD}NO${NC} sensitive information will be send to 3rd party services and will be used ${RED}${BOLD}INSIDE${NC} current server only."
echo "Please run this script under same user you are using to run blockchain node."
echo ""
echo -e "Script sources are avaiable on the ${UNDERLINE}https://github.com/Distributed-Validators-Synctems/validator-online-guard/${NC} repository."
echo ""
echo -e "You always can interupt setup process by pressing ${BOLD}Ctrl+C${NC}."
echo ""
echo "This script may ask you for sudo password because it is required to install additional software: netcat and git-core"
echo "=================================================================="

DEFAULT_PORT="26656"
INSTALLATION_DIR="validator-online-guard"

collect_settings () {
    echo "IP address of the old (remote) node. This address will be used to check old node availability"
    read -p "Old node IP address: " NODE_ADDRESS

    echo ""
    read_number_value "P2P port number" $DEFAULT_PORT
    P2P_PORT=$FUNC_RETURN

    echo ""
    echo "Command used to stop current validator node. Something like 'systemctl stop gaiad.service', or anything suitable."
    read -p "Shutdown command: " KILL_COMMAND

}

show_collected_settings () {
    echo "*************************************************************"
    echo "*                                                           *"
    echo "*  Please carefully check that current settings are right.  *"
    echo "*                                                           *"
    echo "*************************************************************"

    echo ""
    echo "Old node IP address: $NODE_ADDRESS"
    echo "P2P port to check: $P2P_PORT"
    echo "Service shutdown command: $KILL_COMMAND" 

    echo ""
    echo "*************************************************************"
    echo ""
}

read_number_value () {
    local TITLE=$1
    local DEFAULT=$2

    if ! [ -z "$DEFAULT" ]
    then
        local TITLE="${TITLE} (${DEFAULT})"
    fi

    while :
    do
        read -p "${TITLE}: " NUMBER_VALUE

        NUMBER_VALUE=$(echo "$NUMBER_VALUE" | xargs)

        if ! [ -z "$DEFAULT" ] && [ -z "$NUMBER_VALUE" ]
        then
            NUMBER_VALUE=$DEFAULT
            break
        fi

        NUMBER_VALUE=$(echo $NUMBER_VALUE | tr "," ".")

        if [[ $NUMBER_VALUE =~ $FLOAT_RE ]] ; then
            break
        fi

        echo -e "${RED}ERROR!${NC} Wrong number value, please enter another one."
    done   

    FUNC_RETURN=$NUMBER_VALUE 
}

get_boolean_option () {
    local TEXT=$1

    while :
    do
        read -p "$TEXT (y/n): "  BOOLEAN_CHAR_VALUE

        if [ "$BOOLEAN_CHAR_VALUE" = "y" ]; then
            return 1
        fi

        if [ "$BOOLEAN_CHAR_VALUE" = "n" ]; then
            return 0
        fi

        echo -e "${RED}ERROR!${NC} Please choose 'y' or 'n'."
    done
}

install_required_software () {
    sudo apt-get install netcat git-core -y

    local ERROR_NO=$?
    if (( $ERROR_NO > 0 )); then
        exit
    fi
}

create_environment () {
    cat <<__CONFIG_EOF > config.sh
NODE_ADDRESS="$NODE_ADDRESS"
P2P_PORT="$P2P_PORT"
KILL_COMMAND="$KILL_COMMAND"
__CONFIG_EOF
}

fetch_git_repo () {
    local DIR="./script"
    if [[ -d $DIR ]]
    then
        cd $DIR
        git fetch
        git reset --hard HEAD
        git merge origin/master
        cd ..
    else
        git clone https://github.com/Distributed-Validators-Synctems/validator-online-guard.git script
    fi    
}

add_cronjob_tasks () {
    TMPFILE=`mktemp /tmp/cron.XXXXXX`
    PWD=$(pwd)

    crontab -l > $TMPFILE

    CRON_RECORD=$(cat $TMPFILE | grep "# DVS Validator Online Guard")
    if [ -z "$CRON_RECORD" ]
    then
        echo "# DVS Validator Online Guard: Node online checker" >> $TMPFILE
        echo "*/1 * * * * /bin/bash $PWD/script/checker.sh $PWD >>$PWD/checker.log 2>&1" >> $TMPFILE
    fi

    echo "Following crontab job configuration will be added"
    echo ""
    cat $TMPFILE
    
    crontab $TMPFILE
}

install_required_software

while :
do
    collect_settings
    show_collected_settings

    get_boolean_option "Please confirm that settings are correct"
    IS_CORRECT_SETTINGS=$?

    if [ "$IS_CORRECT_SETTINGS" -eq "1" ]; then
        break
    fi
done

mkdir -p $INSTALLATION_DIR
cd $INSTALLATION_DIR

create_environment
fetch_git_repo
add_cronjob_tasks
