#!/bin/bash

function print_string_with_delay() {
    for i in "${1}"
    do
        echo -n "${i}"
        sleep 0.$(((RANDOM % 7) + 1 ))
    done
    echo ""
}

function print_map_characters_with_delay() {
    STRING=$1
    for (( i=0; i<${#STRING}; i++ )); do
        if [[ "${STRING:$i:1}" == "x" ]]
        then
            echo -e -n "${RED_COLOR}"
        elif [[ "${STRING:$i:1}" == "z" ]]
        then
            echo -e -n "${YELLOW_COLOR}"
        else
            echo -e -n "${GREEN_COLOR}"
        fi
        echo -n "${STRING:$i:1}"
        sleep 0.00001
    done
}

function print_defcon_header() {
    echo "  ____  _____ _____ ____ ___  _   _ ";
    echo " |  _ \| ____|  ___/ ___/ _ \| \ | |";
    echo " | | | |  _| | |_ | |  | | | |  \| |";
    sleep 0.4
    echo " | |_| | |___|  _|| |__| |_| | |\  |";
    echo " |____/|_____|_|   \____\___/|_| \_|";
    echo "                                    ";
    echo "------------------------------------"
}

function print_defcon_table {
    ROW="+----+-----------------+-+"
    print_string_with_delay $ROW
    ROW="|CODE|ALERT_DESCRIPTION|S|"
    print_string_with_delay $ROW
    ROW="+----+-----------------+-+"
    print_string_with_delay $ROW
    ROW="|0x5h|NON_OF_ALERT_SPEC"
    if [[ "$1" = 5 ]]
    then
        ROW="$ROW|X|<"
    else
        ROW="$ROW|_|"
    fi
    print_string_with_delay $ROW

    ROW="|0x4h|NON_OF_ALERT_WARN"
    if [[ "$1" = 4 ]]
    then
        ROW="$ROW|X|<"
    else
        ROW="$ROW|_|"
    fi
    print_string_with_delay $ROW

    ROW="|0x3h|ASSAULT_WARNING_1"
    if [[ "$1" = 3 ]]
    then
        echo -e -n "${YELLOW_COLOR}"
        ROW="$ROW|X|<"
    else
        ROW="$ROW|_|"
    fi
    print_string_with_delay $ROW
    echo -e -n "${GREEN_COLOR}"

    ROW="|0x2h|ASSAULT_WARNING_2"
    if [[ "$1" = 2 ]]
    then
        echo -e -n "${YELLOW_COLOR}"
        ROW="$ROW|X|<"
    else
        ROW="$ROW|_|"
    fi
    print_string_with_delay $ROW
    echo -e -n "${GREEN_COLOR}"

    ROW="|0x1h|NUCLEAR_WAR_ALERT"
    if [[ "$1" = 1 ]]
    then
        echo -e -n "${RED_COLOR}"
        ROW="$ROW|X|<"
    else
        ROW="$ROW|_|"
    fi
    print_string_with_delay $ROW
    echo -e -n "${GREEN_COLOR}"

    print_string_with_delay "------------------------------------"
}

function print_static_map {
    while IFS= read -r line
    do
        print_map_characters_with_delay "$line"
        echo ""
    done < "$1"
}

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
YELLOW_COLOR='\033[1;33m'

function main {
    # Set green screen terminal color
    echo -e "${GREEN_COLOR}"

    # Clear screen
    clear

    # Here we will place our header
    print_defcon_header

    # Defcon url
    DEFCON_URL="defconwarningsystem.com"

    # Defcon url for retrieving data
    DEFCON_DATA="https://www.$DEFCON_URL/code.dat"

    print_string_with_delay "> establishing connection to resource..."
    print_string_with_delay "> pending available levels..."
    print_string_with_delay "> checking current defcon level..."

    # Current Defcon level
    DEFCON_LEVEL=$(curl --silent --get $DEFCON_DATA | grep [1-5])

    # Check if we got level from 1 to 5
    if [[ "$DEFCON_LEVEL" =~ ^[1-5]+$ ]]
    then
        print_string_with_delay "> successfuly loaded defcon data..."
    else
        echo -e -n "${RED_COLOR}"
        print_string_with_delay "> error while loading defcon data..."
        print_string_with_delay "> exiting..."
        return -1
    fi

    # Here we will print table with available Defcon levels
    print_defcon_table $DEFCON_LEVEL

    print_string_with_delay "> establishing connection with geo data server..."
    MAP_DATA_FILE="map.ascii"
    $(curl --get "https://raw.githubusercontent.com/MyCatShoegazer/DefconChecker/master/land.ascii" -o $MAP_DATA_FILE)

    MAP_DATA=$(cat $MAP_DATA_FILE)
    if [[ -z "$MAP_DATA" ]]
    then
        echo -e -n "${RED_COLOR}"
        print_string_with_delay "error retrieving geo data..."
        print_string_with_delay "exiting..."
        echo -e -n "${GREEN_COLOR}"
        return -1
    fi

    print_string_with_delay "> loading world map data..."
    print_static_map $MAP_DATA_FILE
    print_string_with_delay "> LEGEND"
    print_map_characters_with_delay "    x - nuclear strike areas"
    print_map_characters_with_delay "    z - safe place"
    echo ""
    print_string_with_delay "> map loaded successfuly..."
}

main
rm map.ascii