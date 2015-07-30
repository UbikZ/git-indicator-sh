#!/usr/bin/env bash

# Check git install
[[ ! $(hash git | wc -l) -eq 0 ]] && echo "Git is not installed." && exit

# Init
CONFIG=()
REPOSITORY=
BASE=$(dirname $0)

# Include
source "$BASE/functions.sh"

# Parameters reading :
while [ ! -z $1 ]; do
    case "$1" in
        -c)
            CONFIG=$(parseConfiguration $2)
            shift
            ;;
        -i)
            REPOSITORY=$2
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo "Wrong options, just check the usage"
            usage
            ;;
    esac
    shift
done

# Main
[ "$CONFIG" == "" ] && CONFIG=$(parseConfiguration)

showRepositoriesSync "${CONFIG[@]}"
