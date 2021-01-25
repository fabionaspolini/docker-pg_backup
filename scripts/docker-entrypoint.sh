#!/bin/sh
set -e

/scripts/pgpass_gen.sh

/scripts/crontab_gen.sh

/scripts/config_gen.sh

exec "$@"
