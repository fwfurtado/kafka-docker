#!/bin/sh

set -e 

requireNonNull() {
    local envvar=$(eval "echo \"\$$1\"")
    
    if [ -z "$envvar" ]; then 
        echo >&2 "Environment var \$$1 must bu specified"
        exit 1 
    fi
}

removeZookeeperChrootFrom() {
    echo $1 | sed -e 's/\/.*$//g'
}

waitingForFirstResponseFrom() {
    servers=$1

    IFS=',' #Internal Field Separator

    for zookeeper_server in $servers; do 
        echo "Waiting 10 seconds for $zookeeper_server"
        wait-for-it $zookeeper_server -q --strict -t 10 -- kafka-server-start.sh config/server.properties && break
    done
}

envsubst < /etc/kafka/config/server.properties > /opt/kafka/config/server.properties

if [ -z "$1" ]; then    
    requireNonNull "ZOOKEEPER_SERVERS"    
    requireNonNull "ADVERTISE_HOST"

    all_zookeeper_servers=$(removeZookeeperChrootFrom $ZOOKEEPER_SERVERS)

    waitingForFirstResponseFrom $all_zookeeper_servers
else
    exec "$@"
fi