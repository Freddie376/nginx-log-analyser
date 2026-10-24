#!/bin/bash
# log-analyser.sh
# Reads an nginx access log and shows the top 5 IP addresses, paths,
# response status codes and user agents.
#
# Usage: ./log-analyser.sh <log-file>

LOG_FILE="$1"

# --- 1. Check the input ---
if [ -z "$LOG_FILE" ]; then
    echo "Error: please give the log file."
    echo "Usage: ./log-analyser.sh <log-file>"
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: '$LOG_FILE' does not exist or is not a file."
    exit 1
fi

if [ ! -r "$LOG_FILE" ]; then
    echo "Error: no permission to read '$LOG_FILE'. Try running with sudo."
    exit 1
fi

if [ ! -s "$LOG_FILE" ]; then
    echo "Error: '$LOG_FILE' is empty."
    exit 1
fi

# --- 2. A reusable function ---
# Reads values from the pipe, counts how many times each appears,
# sorts from most to least, keeps the top 5 and prints them neatly.
# $1 = heading to show, $2 = word to print after the number
show_top5() {
    echo "$1"
    sort | uniq -c | sort -nr | head -n 5 | awk -v unit="$2" '{
        count = $1
        $1 = ""
        sub(/^ /, "")
        printf "%s - %s %s\n", $0, count, unit
    }'
    echo
}

# --- 3. Show the results ---
echo "Log file      : $LOG_FILE"
echo "Total requests: $(wc -l < "$LOG_FILE")"
echo

# Field 1 is the IP address
awk '$1 != "" {print $1}' "$LOG_FILE" \
    | show_top5 "Top 5 IP addresses with the most requests:" "requests"

# Field 7 is the requested path (field 6 is the method, like "GET)
awk '$7 != "" {print $7}' "$LOG_FILE" \
    | show_top5 "Top 5 most requested paths:" "requests"

# Field 9 is the response status code
awk '$9 ~ /^[0-9]+$/ {print $9}' "$LOG_FILE" \
    | show_top5 "Top 5 response status codes:" "requests"

# The user agent is the 6th piece of text when the line is split on double quotes
awk -F'"' 'NF >= 6 && $6 != "" {print $6}' "$LOG_FILE" \
    | show_top5 "Top 5 user agents:" "requests"
