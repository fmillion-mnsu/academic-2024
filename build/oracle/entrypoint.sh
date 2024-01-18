#!/bin/sh

# kick off restore script
/restore.sh &

# run Oracle Database
exec $ORACLE_BASE/$RUN_FILE
