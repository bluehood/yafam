#!/bin/bash

getpath() {
	if `which realpath &>/dev/null`; then
		echo "$(realpath $1)"
	elif `which readlink &> /dev/null`; then
		echo "$(readlink -f $1)"
	else
		echo "$1"
	fi
}

BASEDIR="$(dirname $(getpath $0))"

TOP="$BASEDIR/rules.top"
BOTTOM="$BASEDIR/rules.bottom"
TARGET="$BASEDIR/../fam/rules.d"

if (( $# < 1 )); then
   echo "usage: $0 <rule file>";
   exit 1;
fi

echo -e "// Created by $0 at $(date)\n// from $(getpath $1)" > $TARGET
"$BASEDIR/parser.awk" "$@" | cat "$TOP" - "$BOTTOM" >> "$TARGET"

echo "Created $(getpath $TARGET)." >&2
