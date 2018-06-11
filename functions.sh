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

# /mnt/volumes/backups/$deployment/$type
_TARGET_DIR=${_TARGET_DIR:-/mnt/volumes/backups/${RANCHER_STACK:-geonode-generic}/}

die(){
    echo ${1} > /dev/stderr
    exit 1;
}


# find last file in provided base directory (or subdirs)
# which matches given part of name
# prints directory name or dies
# params
#  DIR_NAME - base dir to search for files
#  FILE_NAME - part of file name to look for
find_last_file(){
    DIR_NAME="${1}"
    FILE_NAME="${2}"
    if [ ! -n "${FILE_NAME}" ]; then
        die "${FILE_NAME} is empty"
    fi;
    if [ ! -d "${DIR_NAME}" ]; then
        die "${DIR_NAME} is not directory"
    fi;
    echo $(find ${DIR_NAME} -type f | grep -i ${FILE_NAME} | grep -v restored | sort -r | head -n 1) 
}

# find last pg dump file
# prints directory name or dies
# params
#  DIR_NAME - base dir to search for dumps
find_last_pg_dump(){
    DIR_NAME="${1}"
    FILE_NAME='pg_dumpall-'
    find_last_file "${DIR_NAME}" "${FILE_NAME}"
}

# find last fs dump file
# prints directory name or dies
# params
#  DIR_NAME - base dir to search for dumps
find_last_fs_dump(){
    DIR_NAME="${1}"
    FILE_NAME='data-'
    find_last_file "${DIR_NAME}" "${FILE_NAME}"
}

# find date in fs dump path
# prints date or die
# TARGET_FILE=/mnt/volumes/backups/geonode-generic-restore//fs/20180607/data-2018_06_07_0959_08.tar.gz
find_fs_date(){
    FILE_NAME="${1}"
    echo $FILE_NAME | sed -ne 's/.*\/\([0-9]\+\).*/\1/gp' || die 'cannot parse date from path' $FILE_NAME
}


set_restore_marker(){
    BASE_FILE=${1}
    MARKER_FILE="${BASE_FILE}.restored"
    touch ${MARKER_FILE}
}

check_restore_marker(){
    BASE_FILE=${1}
    MARKER_FILE="${BASE_FILE}.restored"
    test -f "${MARKER_FILE}"
    RET=$?
    return $RET
}
