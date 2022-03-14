# easyfw.sh

Un simple script pour gerer les regles de filtrage iptables. 
Notamment pratique pour filtrer des pays entiers.

## Fonctionnalitees 

- Bloque ou Accept le traffic venant d'une IP, d'un bloc ou d'un pays
- Possibilite de supprimmer les regles crees precedemment.
- Ne modifie pas la configuration existante

## Prerequis

- iptables doit etre installe et dans PATH
- sudo n'est pas supporte, le script doit etre execute en root

# Utilisation

## Telecharger et executer le script

**Telecharger le script:**  
```console
curl -s https://gitlab.com/snax44/easyfw/-/raw/main/easyfw.sh -o easyfw.sh
```

**Executer le script**
```console
bash easyfw.sh --help
```

```
root@debian:/home/debian# ./easyfw.sh -h

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
