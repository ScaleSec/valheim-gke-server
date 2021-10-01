# GKE Scaler

Scales a node pool to 0 when it is inactive based on cluster metrics

## Requirements

a baseline of metrics (typical metrics when cluster is idle, cpu/mem)
cluster name
node pool name
desired scale up (1 for stateful services like games)

## Env vars
"CLUSTER_NAME"
"PROJECT_ID"
"NODEPOOL_NAME"
"LOCATION"
CONTAINER_NAME
METRICS_BASELINE - This number should be a float which is the value when your server is idle based on the avg last 10 min. Use metrics explorer to find the cpu usage for an avg of 10m when no players are on. The upper bound should be the avg when 1 player is on. E.g "0.2" which means scale down the node pool to 0 when the pod CPU usage is 0.2 for last 10 min