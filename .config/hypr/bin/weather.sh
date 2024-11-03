#!/bin/bash

cache_file="$HOME/.cache/wttr_cache.txt"

if [ ! -f "$cache_file" ]; then
	mkdir -p "$(dirname "$cache_file")" # Create .cache directory if it doesn't exist
	touch "$cache_file"
fi

last_modified=$(stat -c %Y "$cache_file")
current_date=$(date +%s)
time_diff=$((current_date - last_modified))
expiry_time=86400
cached_data=$(<"$cache_file")

if [ $time_diff -lt $expiry_time ] && [ -n "$cached_data" ]; then
	echo "$cached_data" | awk '{
	    for(i=1;i<=NF;i++) {
	        $i=toupper(substr($i,1,1)) tolower(substr($i,2));
	    }
	    $0 = substr($0, 1, length($0)-1) toupper(substr($0, length($0), 1));
	    print
	}'
	exit
fi

response=$(curl -s wttr.in/thrissur?format=%c+%C+%t 2>/dev/null)
city=$response
echo "$city" | awk '{
    for(i=1;i<=NF;i++) {
        $i=toupper(substr($i,1,1)) tolower(substr($i,2));
    }
    $0 = substr($0, 1, length($0)-1) toupper(substr($0, length($0), 1));
    print
}' >"$cache_file"
