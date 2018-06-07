#!/bin/bash

## restore script for fs data
# It will 

THIS_DIR=$(dirname $0)
source ${THIS_DIR}/functions.sh

# /mnt/volumes/backup/$deployment/fs/$date
TARGET_DIR=${_TARGET_DIR}/fs/

TARGET_FILE=$(find_last_fs_dump ${TARGET_DIR})
TARGET_DATE=$(find_fs_date ${TARGET_FILE})

if [ -f "${TARGET_FILE}" ]; then
    echo 'restoring' ${TARGET_FILE}

    cd /
    tar -zvvxf ${TARGET_FILE}

    rclone -vvv --config /root/rclone.conf copy local:${TARGET_DIR}/${TARGET_DATE}/data/ local:/mnt/volumes/data/
    rclone -vvv --config /root/rclone.conf copy local:${TARGET_DIR}/${TARGET_DATE}/statics/  local:/mnt/volumes/statics/ 

    cd -
else
    die "can't find ${TARGET_FILE}"
fi;
