#!/bin/bash

# Invokes the cloud function to scale up server

region="us-east1"
pod_label="app=valheim-server"
function_name="scaleup"
project_id=scaleheim

# check if execution id is in the call. If not, we probably had an error. gcloud CLI doesn't output proper exit codes for errors...
if curl "https://$region-$project_id.cloudfunctions.net/$function_name" -H "Authorization: Bearer $(gcloud auth print-identity-token)" -d "{}"; then
  echo "Server has started. Waiting until it is ready"
else
  echo "Error starting server. Printing scaleup function logs"
  gcloud functions logs read $function_name --region=$region
fi

# You can uncomment this line if you give users access to list pod information. Exercise for reader.
if ! kubectl wait --for=condition=ready --timeout=500s pod -l $pod_label > /dev/null 2>&1 ; then
  echo "No Kubernetes access detected. Server will be ready in about 6 minutes"
else
  echo "Server is ready"
fi