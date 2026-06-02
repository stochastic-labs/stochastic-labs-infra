#!/bin/bash

apk add --no-cache curl python3 2>/dev/null || true

RABBITMQ_HOST="rabbitmq"
RABBITMQ_PORT="15672"
USER="guest"
PASS="guest"

echo "Awaiting RabbitMQ Management API ($RABBITMQ_HOST:$RABBITMQ_PORT) starting..."

while ! curl -s -u "$USER:$PASS" "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/overview" > /dev/null; do
  echo "RabbitMQ loading..."
  sleep 2
done

echo "RabbitMQ ONLINE! Starting provisioning..."

curl -s -u "$USER:$PASS" "http://$RABBITMQ_HOST:$RABBITMQ_PORT/cli/rabbitmqadmin" -o /tmp/rabbitmqadmin
chmod +x /tmp/rabbitmqadmin

echo "rabbitmqadmin ready! Starting topology provisioning..."

RMQ="/tmp/rabbitmqadmin --host=$RABBITMQ_HOST --port=$RABBITMQ_PORT --username=$USER --password=$PASS"

$RMQ declare exchange name=stochastic-exchange type=direct durable=true
$RMQ declare exchange name=stochastic-exchange.dlx type=direct durable=true

$RMQ declare queue name=stochastic-input-queue.dlq durable=true

$RMQ declare queue name=stochastic-input-queue durable=true \
  arguments='{"x-dead-letter-exchange":"stochastic-exchange.dlx", "x-dead-letter-routing-key":"stochastic-routing-key.dlq"}'

$RMQ declare binding source=stochastic-exchange destination=stochastic-input-queue destination_type=queue routing_key=stochastic-routing-key
$RMQ declare binding source=stochastic-exchange.dlx destination=stochastic-input-queue.dlq destination_type=queue routing_key=stochastic-routing-key.dlq

echo "RabbitMQ provisioning completed successfully!"