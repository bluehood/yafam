#!/bin/bash

TOP="rules.top"
BOTTOM="rules.bottom"
TARGET="../fam/rules.d"

if (( $# < 1 )); then
   echo "usage: $0 <rule file>";
   exit 1;
fi

echo -e "// Created by $0 at $(date)\n// from $(realpath $1)" > $TARGET
./parser.awk "$@" | cat "$TOP" - "$BOTTOM" >> "$TARGET"

echo "Created $(realpath $TARGET)." >&2
