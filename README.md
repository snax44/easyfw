# easyfw.sh

A simple script to manage your iptables rules.  
Especially usefull to manage traffic from whole country

:fr: [French version](README_fr.md)

## Features

- Drop or Accept traffic from IP, BlocIP or whole country
- Remove easily your previous rules
- Does not modify existing configuration

## Requirement and Warning note

- iptables has to be installed and in PATH
- Does not support sudo. Has to be run as root

# Usage

## Download and execute the script on your server  

**Download the script:**  
```console
curl -s https://gitlab.com/snax44/easyfw/-/raw/main/easyfw.sh -o easyfw.sh
```

**Run the script:**
```console
root@debian:/home/debian# bash easyfw.sh --help

Deny or Accept traffic from an IP, IP bloc or a whole country.

  Usage:
        ./easyfw.sh --help

    -d  |  --debug             Dry run, only call debug function
    -h  |  --help              Show this help
    -a  |  --accept	       Unblock targets
    -b  |  --block	       Block targets
    -r  |  --remove            Remove IP, IP bloc or country rules
    -c  |  --country	       de,fr,it,uk,us ...
    -i  |  --ip	       	       IP or CIDR

  Examples:
    
    All trafic from IP 1.1.1.1:
      Deny      => ./easyfw.sh --block --ip 1.1.1.1
      Accept    => ./easyfw.sh --accept --ip 1.1.1.1

    All trafic from bloc 1.1.1.0/24:
      Deny      => ./easyfw.sh --block --ip 1.1.1.0/24
      Accept    => ./easyfw.sh --accept --ip 1.1.1.0/24

    All trafic from Germany:
      Deny      => ./easyfw.sh --block --country de
      Accept    => ./easyfw.sh --accept --country de

    Remove existing rules:
      Country   => ./easyfw.sh --remove --country de
      Single IP => ./easyfw.sh --remove --ip 1.1.1.1
      Bloc IP   => ./easyfw.sh --remove --ip 1.1.1.0/24
```
