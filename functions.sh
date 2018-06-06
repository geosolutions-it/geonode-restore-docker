#!/bin/bash

## backup script for postgres db
# define env vars to be used by pg client tools 
# PGUSER
# PGHOST
# PGPORT
# PGDATABASE
# PGOPTIONS

THIS_DIR=$(dirname $0)
ENV_FILE=${THIS_DIR}/.env.cron

if [ -n "${DEBUG}" ]; then
    set -x
    set -h
fi;

# load env file and export values from it to shell
export $(grep -v '^#' ${ENV_FILE} | xargs -d '\n')

echo 'run restore', $(date)
echo 'with env'
env

# /$deployment/pg
_TARGET_DIR=/${RANCHER_STACK:-geonode-generic}/pg/

# /mnt/volumes/backup/$deployment/pg/$date
TARGET_DIR=${TARGET_DIR:-/mnt/volumes/backups/}/${_TARGET_DIR}/


die(){
    echo ${1}
    exit 1;
}


find_last_file(){
    DIR_NAME="${1}"
    FILE_NAME="${2}"
    if [ ! -n "${FILE_NAME}" ]; then
        die "${FILE_NAME} is empty"
    fi;
    if [ ! -d "${DIR_NAME}" ]; then
        die "${DIR_NAME} is not directory"
    fi;
    echo $(find ${DIR_NAME} -type f | grep -i ${FILE_NAME} | sort -r | head -n 1)
}

find_last_pg_dump(){
    DIR_NAME="${1}"
    FILE_NAME='pg_dumpall-'
    find_last_file "${DIR_NAME}" "${FILE_NAME}"
}

find_last_fs_dump(){
    DIR_NAME="${1}"
    FILE_NAME='data-'
    find_last_file "${DIR_NAME}" "${FILE_NAME}"
}
