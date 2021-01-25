#!/bin/sh
set -e

/pgpass_gen.sh

/crontab_gen.sh

/config_gen.sh

exec "$@"
