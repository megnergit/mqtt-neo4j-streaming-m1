#!/bin/bash

# REST endpoint of Kafka Connect
CONNECT_URL="http://localhost:8083/connectors"
CONNECTOR_NAME="neo4j-sink"

# Infos needed to connect to neo4j on Raspberry Pi
NEO4J_URI="bolt://192.168.178.71:7687"  # <- IP of  Raspberry Pi
NEO4J_USER="neo4j"
NEO4J_PASS="test1234"

# Delete existing connector. We will go forward when no connector exists.
curl -X DELETE "${CONNECT_URL}/${CONNECTOR_NAME}" >/dev/null 2>&1

# then create a new connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "neo4j-sink",
    "config": {
      "connector.class": "org.neo4j.connectors.kafka.sink.Neo4jConnector",
      "topics": "iot.sensor01",
      "neo4j.cypher.topic.iot.sensor01": "WITH apoc.convert.fromJsonMap(apoc.text.base64Decode(__value)) AS event CREATE (d:Device {id: event.device_id}) SET d.temp = event.temperature, d.ts = event.timestamp",
      "neo4j.uri": "bolt://192.168.178.71:7687",
      "neo4j.authentication.basic.username": "neo4j",
      "neo4j.authentication.basic.password": "test1234",
      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false",
      "neo4j.topic.cypher.value-type": "string"
    }
  }' | jq

#---------------------
#      "neo4j.cypher.topic.iot.sensor01": "WITH apoc.convert.fromJsonMap(apoc.text.base64Decode(__value)) AS event MERGE (d:Device {id: event.device_id}) SET d.temp = event.temperature, d.ts = event.timestamp",
#     "neo4j.cypher.topic.iot.sensor01": "WITH apoc.convert.fromJsonMap(__value) AS event MERGE (d:Device {id: event.device_id}) SET d.temp = event.temperature, d.ts = event.timestamp",
#=====================    