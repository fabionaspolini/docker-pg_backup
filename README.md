# docker-pg_scripts

Docker container with pg_backup_rotated.sh and pg_backup.sh script from https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux
This image runs pg_backup_rotated.sh daily via cron at configurable time. pg_backup_rotated.sh produces backups of various configurable formats and rotates weekly and daily backups.

Docker environment variables:
 - POSTGRES_HOSTNAME - ip/hostname of postgres server
 - POSTGRES_USER - user to connect as ('postgres' by default)
 - POSTGRES_PASSWORD - password of POSTGRES_USER
 - POSTGRES_PASSWORD_FILE - location of file containing password of POSTGRES_USER (can be /run/secrets/SECRETNAME if you put password in SECRETNAME)
 - CRON_RUN_MINUTE, CRON_RUN_HOUR - run backups daily at this time every day
 - WEEKS_TO_KEEP - how many weeks to keep weekly backups (default 5)
 - DAYS_TO_KEEP - number of days to keep daily backups (default 7)
 - DAY_OF_WEEK_TO_KEEP - which day to take the weekly backup from (1-7 = Monday-Sunday, default 5-Friday)
 - ENABLE_GLOBALS_BACKUPS - will produce gzipped sql file containing the cluster globals, like users and passwords, if set to "yes" (default)
 - ENABLE_PLAIN_BACKUPS - will produce a gzipped plain-format backup if set to "yes" (default)
 - ENABLE_CUSTOM_BACKUPS - will produce a custom-format backup if set to "yes" (default)
 - ENABLE_VACUUM - Wil execute vacumm at databases if set to "yes" (default)
 - ENABLE_ANALYZE - Wil execute analyze at databases if set to "yes" (default)
 - ENABLE_REINDEX - Wil execute reindex at databases if set to "yes" (default)
 - SCHEMA_ONLY_LIST - List of strings to match against in database name, separated by space or comma, for which we only wish to keep a backup of the schema, not the data. Any database names which contain any of these values will be considered candidates. (e.g. "system_log" will match "dev_system_log_2010-01"). Default is empty list.

Volumes:
 - /backups - backups go there

Optional volumes:
- /etc/localtime - map your host /etc/localtime there read-only to have cron operate in host's timezone

You can also tmpfs /var/lib/postgresql/data, it is exported by base image but is not used in this image

The backup script code is taken as-is from postgress wiki, I am not sure which license is it, I claim no rights to this code.
Configuration script is based on config file from postgres wiki. The code that is written by me is in the public domain (CC0). 

## How use this image

Schedule backup from continer in same host machine.

```bash
sudo docker run \
  --name postgres_backup \
  --restart=always \
  --network <docker-network-name> \
  -e POSTGRES_HOSTNAME=<docker-container-name> \
  -e POSTGRES_USER=<pg-user> \
  -e POSTGRES_PASSWORD=<pg-password> \
  -e CRON_RUN_HOUR=0 \
  -e CRON_RUN_MINUTE=0 \
  -e ENABLE_CUSTOM_BACKUPS=yes \
  -e ENABLE_PLAIN_BACKUPS=no \
  -v /backups:/backups \
  fabionaspolini/pg_scripts
```

Schedule backup from network PG Server.

```bash
sudo docker run \
  --name postgres_backup \
  --restart=always \
  -e POSTGRES_HOSTNAME=<pg-server> \
  -e POSTGRES_USER=<pg-user> \
  -e POSTGRES_PASSWORD=<pg-password> \
  -e CRON_RUN_HOUR=0 \
  -e CRON_RUN_MINUTE=0 \
  -e ENABLE_CUSTOM_BACKUPS=yes \
  -e ENABLE_PLAIN_BACKUPS=no \
  -v /backups:/backups \
  fabionaspolini/pg_scripts
```

Execute backup and remove temporary container used in backup.

```bash
sudo docker run --rm \
  --network <docker-network-name> \
  -e POSTGRES_HOSTNAME=<docker-container-name> \
  -e POSTGRES_USER=<pg-user> \
  -e POSTGRES_PASSWORD=<pg-password> \
  -e ENABLE_CUSTOM_BACKUPS=yes \
  -e ENABLE_PLAIN_BACKUPS=no \
  -v /backups:/backups \
  fabionaspolini/pg_scripts /scripts/pg_backup_rotated.sh
```

## How build this image

```bash
sudo docker build --build-arg PG_VERSION=13 -t pg_scripts:13 -t pg_scripts:latest .
sudo docker build --build-arg PG_VERSION=12 -t pg_scripts:12 .
sudo docker build --build-arg PG_VERSION=12 -t pg_scripts:11 .
```

## Source Repository

Official repository: <https://github.com/fabionaspolini/docker-pg_scripts>
