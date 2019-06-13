#!/bin/sh

set -e 

requireNonNull() {
    local envvar=$(eval "echo \"\$$1\"")
    
    if [ -z "$envvar" ]; then 
        echo >&2 "Environment var \$$1 must bu specified"
        exit 1 
    fi
}

envsubst < /etc/kafka/config/server.properties > /opt/kafka/config/server.properties

if [ -z "$1" ]; then    
    
    requireNonNull "ZOOKEEPER_HOST"
    requireNonNull "ZOOKEEPER_PORT"
    requireNonNull "ADVERTISE_HOST"

    wait-for-it $ZOOKEEPER_HOST:$ZOOKEEPER_PORT --strict -t 10 -- kafka-server-start.sh config/server.properties
else
    exec "$@"
fi


