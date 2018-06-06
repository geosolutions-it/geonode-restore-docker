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

TARGET_FILE=$(find_last_pg_dump ${TARGET_DIR})
TARGET_FILE_DECOMPRESSED=${TARGET_FILE::-3}

if [ -f "${TARGET_FILE}" ]; then
    echo 'restoring' ${TARGET_FILE}

    # remove any previously decompressed
    rm -f ${TARGET_FILE_DECOMPRESSED}

    # decompress current
    gunzip -k ${TARGET_FILE}

    # restore with verbose errors
    cat ${TARGET_FILE_DECOMPRESSED} | psql -b

    # cleanup
    rm -f ${TARGET_FILE_DECOMPRESSED}
else
    die "can't find ${TARGET_FILE}"
fi;
