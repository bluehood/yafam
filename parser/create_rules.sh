#!/bin/bash

BASEDIR="$(dirname $(realpath $0))"
TOP="$BASEDIR/rules.top"
BOTTOM="$BASEDIR/rules.bottom"
TARGET="$BASEDIR/../fam/rules.d"

if (( $# < 1 )); then
   echo "usage: $0 <rule file>";
   exit 1;
fi

echo -e "// Created by $0 at $(date)\n// from $(realpath $1)" > $TARGET
"$BASEDIR/parser.awk" "$@" | cat "$TOP" - "$BOTTOM" >> "$TARGET"

echo "Created $(realpath $TARGET)." >&2
