#!/bin/bash
TARGET_URL=$1
echo $TARGET_URL
wget --mirror -rkpN -e robots=off --convert-links -P ./local-dir --user-agent="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:40.0" $TARGET_URL

