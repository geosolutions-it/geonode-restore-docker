#!/bin/bash

## restore script for fs data
# It will restore tar file

THIS_DIR=$(dirname $0)
source ${THIS_DIR}/functions.sh

# /mnt/volumes/backup/$deployment/fs/$date
TARGET_DIR=${_TARGET_DIR}/fs/

TARGET_FILE=$(find_last_fs_dump ${TARGET_DIR})
TARGET_FILE_RET=$?

if [ ! -f ${TARGET_FILE} ] ; then
    die "dump file '${TARGET_FILE}' not found for '${TARGET_DIR}'";
fi;

TARGET_DATE=$(find_fs_date ${TARGET_FILE})

if check_restore_marker "${TARGET_FILE}" ; then
    die "restore marker found for ${TARGET_FILE}"
fi;

if [ -f "${TARGET_FILE}" ]; then
    echo 'restoring' ${TARGET_FILE}

    cd /
    tar -zvvxf ${TARGET_FILE}

    rclone -vvv --config /root/rclone.conf copy local:${TARGET_DIR}/${TARGET_DATE}/data/ local:/mnt/volumes/data/
    rclone -vvv --config /root/rclone.conf copy local:${TARGET_DIR}/${TARGET_DATE}/statics/  local:/mnt/volumes/statics/ 

    cd -
    set_restore_marker ${TARGET_FILE}
else
    die "can't find ${TARGET_FILE}"
fi;
