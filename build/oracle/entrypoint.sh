#!/bin/sh

# ensure that data directory is owned by the correct uid
chown -R 1000 /u01/app/oracle/oradata

# kick off restore script
/restore.sh &

# run Oracle Database
exec $ORACLE_BASE/$RUN_FILE
