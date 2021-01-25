#!/bin/sh
set -e

/scripts/pg_backup_rotated.sh

/scripts/pg_maintenance.sh
