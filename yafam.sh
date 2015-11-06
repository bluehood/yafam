#!/bin/bash

usage() {
        echo "usage: $0 [-b] <def_file> <rule_file>"
        exit 1
}

if (( $# < 2)); then
        usage
fi

while (($# > 0)); do
        case $1 in
        "-b" | "--build") BUILDONLY=true; shift;;
        \-*) usage;;
        *) break;;
        esac
done

DEFS="$1"
RULES="$2"

[[ ! -d bin ]] && mkdir bin
make build &&
./bin/parser "$DEFS" &&
./parser/create_rules.sh "$RULES" &&
make runtime

if [[ $? -eq 0 ]]; then
        [[ $BUILDONLY ]] && ./bin/yafam || exit 0
else
        echo "there was an error building yafam"
        exit 2
fi
