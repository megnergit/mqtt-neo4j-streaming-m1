#!/bin/bash

NAMESPACE="iot-lab"
GROUP_ID="connect-neo4j-sink"
DEPLOY_SCRIPT="./scripts/deploy-neo4j-sink.sh"

BROKER_POD=$(kubectl get pods -n $NAMESPACE -l app=kafka -o jsonpath="{.items[0].metadata.name}")

# get group info
GROUP_OUTPUT=$(kubectl exec -n $NAMESPACE "$BROKER_POD" -- \
  kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group "$GROUP_ID" 2>/dev/null)

# extract CLIENT-ID
CLIENT_ID=$(echo "$GROUP_OUTPUT" | awk -v group="$GROUP_ID" '
  $1 == "GROUP" {
    for (i=1; i<=NF; ++i) {
      if ($i == "CLIENT-ID") col=i
    }
  }
  $1 == group && col > 0 {
    print $col
  }
')

echo "CLIENT_ID(s): $CLIENT_ID"

# if CONSUMER-ID is "-", considered as failed
ACTIVE_MEMBER_COUNT=$(echo "$GROUP_OUTPUT" | grep -v "TOPIC" | awk '{print $7}' | grep -vc '^-$')

# echo "${GROUP_OUTPUT}" | tee tmp/group_output.txt
# echo "${ACTIVE_MEMBER_COUNT}"

# if [[ "$ACTIVE_MEMBER_COUNT" -eq 0 ]]; then
if [[ "$CLIENT_ID" == "-" ]]; then
  echo "[$(date)] Consumer group '$GROUP_ID' has NO active members. Redeploying connector..."
  $DEPLOY_SCRIPT
else
  echo "[$(date)] Consumer group '$GROUP_ID' is active ($ACTIVE_MEMBER_COUNT members). No action needed."
fi
