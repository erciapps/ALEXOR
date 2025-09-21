#!/usr/bin/env bash
#   Use this script to test if a given TCP host/port are available

set -e

TIMEOUT=60
QUIET=0

echoerr() { if [ $QUIET -ne 1 ]; then echo "$@" 1>&2; fi }

usage()
{
    exitcode="$1"
    cat << USAGE >&2
Usage:
    wait-for-it host:port [-t timeout] [-- command args]
USAGE
    exit "$exitcode"
}

wait_for()
{
    for i in `seq $TIMEOUT` ; do
        nc -z "$HOST" "$PORT" > /dev/null 2>&1 && return 0
        sleep 1
    done
    return 1
}

while [ $# -gt 0 ]
do
    case "$1" in
        *:* )
        HOST=$(printf "%s\n" "$1"| cut -d : -f 1)
        PORT=$(printf "%s\n" "$1"| cut -d : -f 2)
        shift 1
        ;;
        -t)
        TIMEOUT="$2"
        if [ "$TIMEOUT" = "" ]; then break; fi
        shift 2
        ;;
        --)
        shift
        CMD="$@"
        break
        ;;
        *)
        usage 1
        ;;
    esac
done

if wait_for; then
    if [ -n "$CMD" ]; then
        exec $CMD
    fi
    exit 0
else
    echo "Timeout occurred waiting for $HOST:$PORT"
    exit 1
fi
