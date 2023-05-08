#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Starting tunnel ..."
    code tunnel --accept-server-license-terms &
    PID=$!
    trap "kill $PID" SIGINT SIGTERM
    wait $PID
    echo "Unregistering tunnel ..."
    code tunnel unregister
else
    exec "$@"
fi
