#!/bin/bash
###
#
# Author: snax44
# Date: 2021.08.23
# Version: 1.0
# Desc: Ban or unban easily ip or country range ip
###
#############
### Variables

# To personnalize
DEBUG=false                                                                                         # Set to true to go directly in debug function after option parsing
REQUIRE_ROOT=true                                                                                  # Set to true if this script need to be run as root
REQUIRE_OPTION=true                                                                                # Set to true if this script cannot be ran without any options
CONTINUE_ON_UNDETECTED_OS=true                                                                     # Script will continue even if the has not been correctly detected
MY_REPO_URL="https://gitlab.com/snax44/easyfw"                                                      # Put here link to the git repository

###
OS_DETECTED="$(awk '/^ID=/' /etc/*-release 2> /dev/null | awk -F'=' '{ print tolower($2) }' )"      # Get the os name
USER_ID=$(id -u)                                                                                    # Nothing to say here


#####################
### Commons functions
# Basic function that will be call if DEBUG is set to true

function debug(){
  cat << EOF

  Debug mode:
  -----------------------------
  Require root              : $REQUIRE_ROOT
  Require options           : $REQUIRE_OPTION
  Continue on undetected OS : $CONTINUE_ON_UNDETECTED_OS
  Git Link                  : $MY_REPO_URL
  OS Detected               : $OS_DETECTED
  User ID                   : $USER_ID

  Action		    : $ACTION
  Method                    : $METHOD
  Target                    : $TARGET
  -----------------------------

EOF
}

function usage(){
  cat <<EOF

blablablabla

  Usage:
        $0 --help

    -d  |  --debug             Do nothing dangerous, only call debug function
    -h  |  --help              Show this help
    -a  |  --accept	       Unblock targets
    -b  |  --block	       Block targets
    -c  |  --country	       de,fr,it,uk,us ...
    -i  |  --ip	       	       IP or CIDR

EOF
}

function msg(){
  # Call this function to print a beautifull colored message
  # Ex: msg ko "This is an error"

  local GREEN="\\033[1;32m"
  local NORMAL="\\033[0;39m"
  local RED="\\033[1;31m"
  local PINK="\\033[1;35m"
  local BLUE="\\033[1;34m"
  local WHITE="\\033[0;02m"
  local YELLOW="\\033[1;33m"

  if [ "$1" == "ok" ]; then
    echo -e "[$GREEN  OK  $NORMAL] $2"
  elif [ "$1" == "ko" ]; then
    echo -e "[$RED ERROR $NORMAL] $2"
  elif [ "$1" == "warn" ]; then
    echo -e "[$YELLOW WARN $NORMAL] $2"
  elif [ "$1" == "info" ]; then
    echo -e "[$BLUE INFO $NORMAL] $2"
  fi
}

function detect_os(){
  # Do what you want or need accoring the detected os
  # By default this will just print an info message with then OS name.
  # You just have to write not_supported_os in one of the following if do make it not compatible

  if [[ "$OS_DETECTED" == "debian" ]]; then
    msg info "OS detected : Debian"
  elif [[ "$OS_DETECTED" == "ubuntu" ]]; then
    msg info "OS detected : Ubuntu"
  elif [[ "$OS_DETECTED" == "fedora" ]]; then
    msg info "OS detected : Fedora"
  elif [[ "$OS_DETECTED" == "centos" ]]; then
    msg info "OS detected : Centos"
  elif [[ "$OS_DETECTED" == "arch" ]]; then
    msg info "OS detected : Archlinux"
  else
    if $CONTINUE_ON_UNDETECTED_OS; then
      msg warn "Unable to detect os. Keep going anyway in 5s"
    else
      msg ko "Unable to detect os and CONTINUE_ON_UNDETECTED_OS is set to false"
      exit 1
    fi
  fi

  function not_supported_os(){
    msg ko "Oops This OS is not supported yet !"
    echo "    Do not hesitate to contribute for a better compatibility
              $MY_REPO_URL"
    exit 1
  }
}

#################
### Main function
function main(){

  function country(){
    BASE_URL="http://www.ipdeny.com/ipblocks/data/aggregated"
    OUTPUT_FILE="/tmp/$TARGET.zone"
    
    msg info "Let's $ACTION trafic from: $TARGET"
    msg info "Download the list from $BASE_URL/$TARGET-aggregated.zone"
    wget -q $BASE_URL/$TARGET-aggregated.zone -O $OUTPUT_FILE
    
    NB_ENTRY=$(wc -l < $OUTPUT_FILE)
    msg info "The list has been downloaded in $OUTPUT_FILE and contain $NB_ENTRY entry."    
    
    SECONDS="0"
    msg info "Processing..." 
    
    
    if [[ "$ACTION" = "ACCEPT" ]]; then
      iptables -N country-$TARGET > /dev/null 2>&1
      iptables -A INPUT -j country-$TARGET > /dev/null 2>&1
      
      for LINE in $(cat $OUTPUT_FILE); do
        accept_ip $LINE
      done
      
      if [[ "$?" == 0 ]]; then
        msg ok "$NB_ENTRY were successfully added as accepted rules in the firewall in $SECONDS seconds"
      else
        msg ko "Something wrong happened !"
        exit
      fi
      iptables -A country-$TARGET -j RETURN 
    
    elif [[ "$ACTION" = "REMOVE" ]]; then
      if [[ "$METHOD" = "COUNTRY" ]]; then
        iptables -F country-$TARGET > /dev/null 2>&1
        iptables -D INPUT -j country-$TARGET > /dev/null 2>&1
        iptables -X country-$TARGET > /dev/null 2>&1
      elif [[ "$METHOD" = "IP" ]]; then
        iptables -D INPUT -s $TARGET > /dev/null 2>&1
      fi

      if [[ "$?" == 0 ]]; then
        msg ok "$TARGET $IP has been successfully removed from the firewall in $SECONDS seconds"
      else
        msg ko "Something wrong happened !"
        exit
      fi

    elif [[ "$ACTION" = "DROP" ]]; then
      iptables -N country-$TARGET > /dev/null 2>&1
      iptables -A INPUT -j country-$TARGET > /dev/null 2>&1
      
      for LINE in $(cat $OUTPUT_FILE); do
        block_ip $LINE
      done
      if [[ "$?" == 0 ]]; then
        msg ok "$NB_ENTRY were successfully added to the firewall in $SECONDS seconds"
      else
        msg ko "Something wrong happened !"
      fi
      iptables -A country-$TARGET -j RETURN 
    fi
  }

  function block_ip(){
    if [[ "$METHOD" = "COUNTRY" ]]; then
      iptables -A country-$TARGET -s $1 -j DROP > /dev/null 2>&1
    else 
      iptables -A INPUT -s $1 -j DROP > /dev/null 2>&1  
    fi
  } 

  function accept_ip(){
    if [[ "$METHOD" = "COUNTRY" ]]; then
      iptables -A country-$TARGET -s $1 -j ACCEPT > /dev/null 2>&1
    else 
      iptables -A INPUT -s $1 -j ACCEPT > /dev/null 2>&1  
    fi
  }
  
  function remove_ip(){
      iptables -D INPUT -s $1 -j DROP > /dev/null 2>&1  
  }
  


  if [[ "$METHOD" = "COUNTRY" ]]; then
    country
  elif [[ "$METHOD" = "IP" ]]; then
    if [[ "$ACTION" = "REMOVE" ]]; then
      if [[ "$TARGET" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]|[12][0-9]|3[012]$ ]]; then
        msg info "Let's $ACTION rule for this IP bloc: $TARGET"
        remove_ip $TARGET
      elif [[ "$TARGET" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        msg info "Let's $ACTION rule for this IP: $TARGET"
        remove_ip $TARGET
      fi
    elif [[ "$ACTION" = "DROP" ]]; then
      if [[ "$TARGET" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]|[12][0-9]|3[012]$ ]]; then
        msg info "Let's $ACTION traffic from this IP bloc: $TARGET"
        block_ip $TARGET
      elif [[ "$TARGET" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        msg info "Let's $ACTION traffic from this IP: $TARGET"
        block_ip $TARGET
      fi
    elif [[ "$ACTION" = "ACCEPT" ]]; then
      if [[ "$TARGET" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]|[12][0-9]|3[012]$ ]]; then
        msg info "Let's $ACTION traffic from this IP bloc: $TARGET"
        accept_ip $TARGET
      elif [[ "$TARGET" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        msg info "Let's $ACTION traffic from this IP: $TARGET"
        accept_ip $TARGET
      fi
    fi
  fi

}

##################
### Commons checks

if [ $USER_ID -ne 0 ] && $REQUIRE_ROOT ; then
   msg ko "Oops, this script must be run as root !"
   exit 1
fi

if [[ $# -eq 0 ]] && $REQUIRE_OPTION; then
  msg ko "Oops, This script require options"
  usage
  exit 1
fi

# Parsing positional option and arguments

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -d | --debug)
      DEBUG=true
      shift 1
      ;;
    -a | --accept)
      ACTION="ACCEPT"
      shift 1
      ;;
    -b | --block)
      ACTION="DROP"
      shift 1
      ;;
    -r | --remove)
      ACTION="REMOVE"
      shift 1
      ;;
    -c | --country)
      METHOD="COUNTRY"
      TARGET="$2"
      shift 2
      ;;
    -i | --ip)
      METHOD="IP"
      TARGET="$2"
      shift 2
      ;;
      *)
      msg ko "$1 : Unkown option"
      usage
      exit 1
      ;;
  esac
done

detect_os

if $DEBUG; then
  debug
  exit 0
else
  main
fi
