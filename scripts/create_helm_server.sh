#!/bin/bash

stty -echo
printf "Password: "
read -r PASSWORD
stty echo
printf "\n"

bucket_name="scaleheim-ooakd921407124k2"

helm "$1" valheim-server helm/chart  \
  --set password="$PASSWORD" \
  --set extraEnvironmentVars.POST_BACKUP_HOOK="gsutil cp @BACKUP_FILE@ gs://${bucket_name}/scaleheim.zip"