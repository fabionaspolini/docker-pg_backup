#!/bin/sh
set -e

if [ ! -z "$POSTGRES_PASSWORD_FILE" ]
then
  export PGPASSWORD="`cat ${POSTGRES_PASSWORD_FILE}`"
else
  export PGPASSWORD="${POSTGRES_PASSWORD}"
fi

echo "*:*:*:${POSTGRES_USER-postgres}:$PGPASSWORD" > /root/.pgpass
chmod 0600 /root/.pgpass
