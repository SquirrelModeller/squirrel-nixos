#!/usr/bin/env bash

count=0
total=60
running=true

update_count() {
    echo "{\"count\": $count, \"total\": $total}"
}

start() {
    running=true
    total=$1
    count=0
    update_count
}

stop() {
    running=false
    update_count
}

reset() {
    count=0
    update_count
}

set_timer() {
    total=$1
    count=0
    update_count
}

case "$1" in
    start)
        start $2
        ;;
    stop)
        stop
        ;;
    reset)
        reset
        ;;
    set)
        set_timer $2
        ;;
    *)
        while true; do
            if $running; then
                count=$((count + 1))
                if [ $count -gt $total ]; then
                    count=$total
                    reset
                fi
            fi
            update_count
            sleep 1
        done
        ;;
esac