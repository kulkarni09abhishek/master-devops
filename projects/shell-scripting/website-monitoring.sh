#!/bin/bash

# This is website monitoring project

# Goal - 1) Monitor a website on timely basis. 
#        2) Add the result (status_code and response_time) to a log file.
#        3) Archive the result on daily basis

# website url
URL="https://github.com"


# create log directory
LOG_DIR="$HOME/website_health_logs"
mkdir -p "$LOG_DIR"

# log file
TODAY=$(date +"%y-%m-%d")
LOG_FILE="$LOG_DIR/health_log_$TODAY.log"

# get response
response=$(curl -o /dev/null -s -A "Chrome" -w "%{http_code} %{time_total}" "$URL")

# fetch status_code and response_time from response
status_code=$(echo "$response" | awk '{print $1}')
response_time=$(echo "$response" | awk '{print $2}')

timestamp=$(date +"%y-%m-%d %H:%M:%S")

# append log file
echo "$timestamp | Status: $status_code | Response Time: ${response_time}s" >> "$LOG_FILE"


# Archive previous day's logs — runs only once per day
ARCHIVE_DIR="$LOG_DIR/archive"
ARCHIVE_MARKER="$LOG_DIR/.archived_$TODAY"

if [ ! -f "$ARCHIVE_MARKER" ]; then
    mkdir -p "$ARCHIVE_DIR"
    for log_file in "$LOG_DIR"/health_log_*.log; do
        [ -f "$log_file" ] || continue
        if [ "$log_file" != "$LOG_FILE" ]; then
            filename=$(basename "$log_file")
            tar -czf "$ARCHIVE_DIR/${filename}.tar.gz" -C "$LOG_DIR" "$filename" && rm -f "$log_file"
            echo "Archived: $filename"
        fi
    done
    touch "$ARCHIVE_MARKER"
fi



# add this to crontab using `crontab -e`
# add line -> * * * * * /path/to/website-monitoring.sh
# this will run the script every minute.