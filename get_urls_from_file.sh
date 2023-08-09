#/bin/bash
TARGET_FILE=$1
grep -Eoi '<a [^>]+>' $TARGET_FILE | grep -Eo 'href="[^\"]+”' | grep -Eo '(http|https)://[^”]+'
