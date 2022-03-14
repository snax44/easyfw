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
bash easyfw.sh --help
```
