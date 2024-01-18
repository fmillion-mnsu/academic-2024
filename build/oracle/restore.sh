#!/bin/sh

# If data restore was performed before, skip.
if [ -f /u01/app/oracle/oradata/.configured ]; then exit 0; fi

echo "[loader] Oracle Loader v.2024 (flint.million@mnsu.edu)"

# make log output dir if it doesn't exist
mkdir -p /log

echo "*** Oracle Loader v.2024 ***" > /log/loader.log
echo "*** Startup time: `date` ***" >> /log/loader.log

echo "[loader] Waiting for Oracle Database to start."

echo "Waiting for database..." >> /log/loader.log

# wait for the server to start
until $ORACLE_BASE/$CHECK_DB_FILE
do
    #echo "[loader] Database is not yet ready."
    sleep 15
done

echo "Database is ready at `date`" >> /log/loader.log

echo "[loader] Database is ready. Beginning data preload procedure."

if [ -d /preload ]; then

    # Discover accounts
    echo "[loader] Discovering accounts..."
    if [ -f /preload/accounts.txt ]; then
        ACCTS=()
        while IFS= read -r line
        do
            read -ra line_parts <<<"$line"
            if [ ${#line_parts[@]} -ne 2 ]; then
                echo "[loader] WARNING: skipping '$line' (incorrect token count)"
                continue
            fi
            #echo ${#line_parts[@]}
            #echo "user: ${line_parts[0]} password: ${line_parts[1]}"
            ACCTS+=("${line_parts[0]} ${line_parts[1]}")
        done < "/preload/accounts.txt"
    else
        ACCTS=("student password")
        echo "[loader] WARNING: Account file missing, using default configuration of one account 'Student:Password'."
    fi

    echo "[loader] Account discovery complete, ${#ACCTS[@]} accounts discovered."

    for db in /preload/*.sql; do

        DB_BASENAME=`basename $db`
        DB_NAME=${DB_BASENAME%.sql}
        echo "[loader] Running preload for database '$DB_NAME'."

        for user in "${ACCTS[@]}"; do

            read -ra user_parts <<<"$user"
            DB_USER=${user_parts[0]}_${DB_NAME}
            DB_PASS=${user_parts[1]}

            echo "[loader] Creating database user '$DB_USER' with password \'$DB_PASS\'."

            echo "************ $DB_USER ************" >> /log/loader.log

            echo "CREATE USER $DB_USER IDENTIFIED BY \"$DB_PASS\";" > /tmp/create.txt
            echo "GRANT CREATE SESSION TO $DB_USER;" >> /tmp/create.txt
            echo "GRANT CONNECT TO $DB_USER;" >> /tmp/create.txt
            echo "GRANT ALL PRIVILEGES TO $DB_USER;" >> /tmp/create.txt
            #echo "GRANT SYSDBA TO $DB_NAME;" >> /tmp/create.txt
            echo "------------ Running this create script ------------" >> /log/loader.log
            cat /tmp/create.txt >> /log/loader.log
            echo "----------------------------------------------------" >> /log/loader.log

            sqlplus sys@localhost/$ORACLE_PWD as sysdba @/tmp/create.txt 2>&1 >>/log/loader.log

            # load the data
            echo "[loader] Loading data from '$db' to '$DB_USER' tablespace."
            echo "------------ Running database load script -------------" >> /log/loader.log

            sqlplus $DB_USER@localhost/$DB_PASS @$db 2>&1 >>/log/loader.log

            echo "----------------------------------------------------\n" >> /log/loader.log

            rm /tmp/create.txt
        done
    done
else
    echo "[loader] No data to preload. Skipping preload step."
fi

echo "[loader] Loading completed."

echo "Loader completed at `date`" >> /log/loader.log
touch /u01/app/oracle/oradata/.configured
