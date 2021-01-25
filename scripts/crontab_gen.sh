#!/bin/sh
#set -e

echo "${CRON_RUN_MINUTE-0} ${CRON_RUN_HOUR-0} * * * /scripts/pg_backup_rotated.sh" >/etc/crontabs/root
