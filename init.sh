#!/bin/bash

# Load the .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found!"
  exit 1
fi

# Check if EXISTDB_ADMIN_PASSWORD is set
if [ -z "$EXISTDB_ADMIN_PASSWORD" ]; then
  echo "Error: EXISTDB_ADMIN_PASSWORD is not set in the .env file"
  exit 1
fi

echo "Changing the admin password"
docker exec $DOCKER_CONTAINER_NAME java org.exist.start.Main client -q -u admin -P '' -x "sm:passwd('admin', \"$EXISTDB_ADMIN_PASSWORD\")"

if [ -n "$ACCOUNT_TO_DISABLE" ]; then
    IFS=','
    for account in $ACCOUNT_TO_DISABLE; do
        echo "Disabling: $account"
        docker exec $DOCKER_CONTAINER_NAME java org.exist.start.Main client -q -u admin -P $EXISTDB_ADMIN_PASSWORD -x "sm:set-account-enabled(\"$account\", false())"
    done
fi
