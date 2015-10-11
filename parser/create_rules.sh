#!/bin/bash

TOP="rules.top"
BOTTOM="rules.bottom"
TARGET="../fam/rules.d"

if (( $# < 1 )); then
   echo "usage: $0 <rule file>";
   exit 1;
fi

./parser.awk "$@" | cat "$TOP" - "$BOTTOM" > "$TARGET"
