#!/bin/bash

THIS_DIR=$(dirname $0)

env > ${THIS_DIR}/.env.cron
echo 'dumped env'
cat ${THIS_DIR}/.env.cron


${THIS_DIR}/pg_restore.sh
${THIS_DIR}/fs_restore.sh

