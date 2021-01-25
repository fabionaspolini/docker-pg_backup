#!/bin/bash

###########################
####### LOAD CONFIG #######
###########################

while [ $# -gt 0 ]; do
        case $1 in
                -c)
                        CONFIG_FILE_PATH="$2"
                        shift 2
                        ;;
                *)
                        ${ECHO} "Unknown Option \"$1\"" 1>&2
                        exit 2
                        ;;
        esac
done

if [ -z $CONFIG_FILE_PATH ] ; then
        SCRIPTPATH=$(cd ${0%/*} && echo "/root")
        CONFIG_FILE_PATH="${SCRIPTPATH}/pg_backup.config"
fi

if [ ! -r ${CONFIG_FILE_PATH} ] ; then
        echo "Could not load config file from ${CONFIG_FILE_PATH}" 1>&2
        exit 1
fi

source "${CONFIG_FILE_PATH}"

###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ] ; then
	echo "This script must be run as $BACKUP_USER. Exiting." 1>&2
	exit 1
fi


###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $HOSTNAME ]; then
	HOSTNAME="localhost"
fi;

if [ ! $USERNAME ]; then
	USERNAME="postgres"
fi;


###############################
#### START THE MAINTENANCE ####
###############################

function perform_maintenance()
{
	############################
	######     MANUT     #######
	############################

	for SCHEMA_ONLY_DB in ${SCHEMA_ONLY_LIST//,/ }
	do
		EXCLUDE_SCHEMA_ONLY_CLAUSE="$EXCLUDE_SCHEMA_ONLY_CLAUSE and datname !~ '$SCHEMA_ONLY_DB'"
	done

	FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn $EXCLUDE_SCHEMA_ONLY_CLAUSE order by datname;"

	echo -e "\n\nPerforming database maintenance"
	echo -e "--------------------------------------------\n"

	#############################
	######     VACUUM     #######
	#############################

	if [ $ENABLE_VACUUM = "yes" ]
	then
		VACUUM_CMD="vacuum"
		if [ $ENABLE_ANALYZE="yes" ]
		then
			VACUUM_CMD="vacuum analyze"
		fi

		for DATABASE in `psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres`
		do
			echo "$VACUUM_CMD of $DATABASE"

			if ! psql -h "$HOSTNAME" -U "$USERNAME" --dbname=$DATABASE -c "$VACUUM_CMD"; then
				echo "[!!ERROR!!] Failed to execute maintenance database $DATABASE"
			fi
		done
	fi

	##############################
	######     REINDEX     #######
	##############################

	if [ $ENABLE_REINDEX = "yes" ]
	then
		for DATABASE in `psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres`
		do
			echo "Reindexing database $DATABASE"
			REINDEX_CMD="reindex database \"$DATABASE\""
			if ! psql -h "$HOSTNAME" -U "$USERNAME" --dbname=$DATABASE -c "$REINDEX_CMD"; then
				echo "[!!ERROR!!] Failed to execute reindex database $DATABASE"
			fi
		done
	fi

	echo -e "\nAll database maintenance complete!"
}

perform_maintenance
