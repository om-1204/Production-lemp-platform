#!/bin/bash

THRESHOLD=4.0

LOAD=$(awk '{print $1}' /proc/loadavg)

if awk "BEGIN {exit !($LOAD >= $THRESHOLD)}"; then
    echo "[ALERT] High load average: $LOAD"
    exit 2
else
    echo "[OK] Load average: $LOAD"
    exit 0
fi
