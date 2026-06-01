#!/bin/bash

KAFKA_BROKER="kafka:29092"

echo "Awaiting broker Kafka ($KAFKA_BROKER) starting..."

while ! kafka-topics --bootstrap-server $KAFKA_BROKER --list > /dev/null 2>&1; do
  echo "Kafka loading..."
  sleep 2
done

echo "Kafka ONLINE! START..."

TOPIC_NAME="stochastic-topic-name"
PARTITIONS=3
REPLICATION_FACTOR=1

kafka-topics \
  --bootstrap-server $KAFKA_BROKER \
  --create \
  --if-not-exists \
  --topic $TOPIC_NAME \
  --partitions $PARTITIONS \
  --replication-factor $REPLICATION_FACTOR

echo "Topic '$TOPIC_NAME' created!"