#/bin/bash
grep -Eoi '<a [^>]+>' $1 | grep -Eo 'href="[^\"]+”' |grep -Eo '(http|https)://[^”]+'
