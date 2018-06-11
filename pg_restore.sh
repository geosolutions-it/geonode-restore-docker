#!/bin/bash

## backup script for postgres db
# define env vars to be used by pg client tools 
# PGUSER
# PGHOST
# PGPORT
# PGDATABASE
# PGOPTIONS

THIS_DIR=$(dirname $0)
source ${THIS_DIR}/functions.sh

# /mnt/volumes/backup/$deployment/pg/$date
TARGET_DIR=${_TARGET_DIR}/pg/

TARGET_FILE=$(find_last_pg_dump ${TARGET_DIR})
TARGET_FILE_RET=$?

if [ ! -f ${TARGET_FILE} ] ; then
    die "dump file '${TARGET_FILE}' not found for '${TARGET_DIR}'";
fi;

# TARGET_FILE has .gz suffix
TARGET_FILE_DECOMPRESSED=${TARGET_FILE::-3}

if  check_restore_marker "${TARGET_FILE}"; then
    die "restore marker found for ${TARGET_FILE}"
fi;

if [ -f "${TARGET_FILE}" ]; then
    echo 'restoring' ${TARGET_FILE}

    # remove any previously decompressed
    rm -f ${TARGET_FILE_DECOMPRESSED}

    # decompress current
    gunzip -k ${TARGET_FILE}

    # restore with verbose errors
    echo "drop database geonode;
          \c template1;
          drop database postgres;
          drop database geonode_data;
          UPDATE pg_database SET datistemplate='false' WHERE datname='template_postgis';
          drop database template_postgis;
          create database postgres owner postgres" | psql -b -d template1
    psql -l
    cat ${TARGET_FILE_DECOMPRESSED} | psql -b -d template1

    # cleanup
    rm -f ${TARGET_FILE_DECOMPRESSED}
    set_restore_marker ${TARGET_FILE}
else
    die "can't find ${TARGET_FILE}"
fi;
