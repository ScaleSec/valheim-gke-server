#!/bin/bash

set -e

for dir in *; do
  if [[ -d "$dir" ]]; then
    echo "Testing $dir"
    (
      cd "$dir" || exit 1
      go test
    )
  fi
done