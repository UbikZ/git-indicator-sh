#!/usr/bin/env bash

# Init
BASE=$(dirname $0)

# Include
source "$BASE/colors.sh"

# Business Functions

function usage {
    echo 'Usage : git-indicator.sh -c <config_file> -i <repository> --check --help
          -c file           set a configuration file with preset repositories
          -i repository     ask sync information about one repository
          --fetch           force fetch each time
          --help            help
          '
    exit 0
}

function parseConfiguration {
    CONFIG=()
    if [ ! -f "$BASE/$1" ]; then
        CONFIG=$(find ~/ -type d -name '*.git' | sed "s/\.git//g" | egrep -v '(bundle|tests|vendor|.composer)')
    else
        for line in $(cat $BASE/$1); do
            CONFIG+=("$line")
        done
    fi
    echo "${CONFIG[@]}"
}

function fetch {
    REPOSITORY=$1
    CACHE_FILE="~/.gitsh.cache"
    LIFETIME=300
    
    [ -f "$CACHE_FILE" ] && DURATION=$(cat $CACHE_FILE) || DURATION=0
    
    diffTime=0 #$(($(date +%s) - $DURATION))
    result=1
    if [[ $diffTime -ge $LITEFIME ]]; then
        echo "test"
        #(git fetch -q $REPOSITORY >/dev/null && echo $(date +%s) > $CACHE_FILE) || result=-1
    fi
    echo $result
}

function gitDiffCountCommits {
    REPOSITORY="$1"
    SRC_BRANCH="master"

    checkRepository "$REPOSITORY"
    [ "$2" == "" ] && SRC_BRANCH="$2"
    DEST_BRANCH="master"
    [ "$3" == "" ] && DEST_BRANCH="$3"
    cd "$1" && \
    (git fetch >/dev/null || echo -1) && (git rev-list $2..origin/$3 --count 2>/dev/null || echo -1) && cd "$BASE"
}

function gitCountCommits {
    REPOSITORY="$1"

    checkRepository "$REPOSITORY"
    cd "$REPOSITORY" && (git rev-list HEAD --count 2>/dev/null || echo -1) && cd "$BASE"
}

function checkRepository {
    [ ! -d "$1/.git" ] && echo "$1 is not a git repository" && exit 0
}

function showRepositoriesSync {
    if [ "$1" == "" ]; then
        echo "No configuration found."
    else
        for repository in $1; do
            countCommits=$(gitCountCommits "$repository")
            countDiffCommits=$(gitDiffCountCommits "$repository" "master" "master")
            op=$(($countCommits-$countDiffCommits))
            [ $countCommits -eq -1 ] && percent=" - " || percent=$((100*$op/$countCommits))
            [ "$percent" == "100" ] && color="$green" || color="$yellow"
            [ "$percent" == " - " ] && color="$red"

            echo -e "$yellow > $white $repository ($color $percent%$white )$default"
        done
    fi
}

