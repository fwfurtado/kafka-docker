FROM alpine as builder

RUN 	mkdir -p opt/kafka && \ 
		wget https://www-eu.apache.org/dist/kafka/2.2.0/kafka_2.11-2.2.0.tgz -qO- | tar zxf - -C /opt/kafka --strip-components 1 


FROM openjdk:8-jre-slim

RUN mkdir -p /var/lib/kafka && \
	apt-get update && \
	apt-get install -y wait-for-it gettext-base && \
	rm -rf /var/lib/apt/lists/* 

COPY --from=builder /opt/kafka /opt/kafka  
COPY assets/server.properties /etc/kafka/config/server.properties

EXPOSE 9092

WORKDIR /opt/kafka

VOLUME [ "/var/lib/kafka" ]

COPY assets/docker-entrypoint.sh /usr/local/bin/

ENV 	PATH="/opt/kafka/bin:${PATH}" \
		BROKER_ID=0 		

ENTRYPOINT ["docker-entrypoint.sh"]