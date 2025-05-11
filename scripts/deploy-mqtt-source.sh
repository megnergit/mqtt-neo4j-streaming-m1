#!/bin/bash

# Kafka Connect REST endpoint (as we are port-forwarding, localhost:8083)
CONNECT_URL="http://localhost:8083/connectors"

# Connector name
CONNECTOR_NAME="mqtt-source"

# Delete existing conenctor first. We will ignore error when no connector exists.
curl -X DELETE "${CONNECT_URL}/${CONNECTOR_NAME}" >/dev/null 2>&1

# Create a new connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" -d '{
  "name": "mqtt-source",
  "config": {
    "connector.class": "io.lenses.streamreactor.connect.mqtt.source.MqttSourceConnector",
    "tasks.max": "1",
    "connect.mqtt.connection.clean": "true",
    "connect.mqtt.connection.timeout": "1000",
    "connect.mqtt.kcql": "INSERT INTO iot.sensor01 SELECT * FROM iot/sensor01",
    "connect.mqtt.client.id": "mqtt-kafka-01",
    "connect.mqtt.hosts": "tcp://mosquitto.iot-lab.svc.cluster.local:1883",
    "connect.mqtt.keep.alive.interval": "1000",
    "connect.mqtt.service.quality": "1",
    "connect.mqtt.persistence": "memory",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false"
  }
}' | jq

