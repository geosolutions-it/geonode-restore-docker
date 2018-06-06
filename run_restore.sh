#!/bin/bash

THIS_DIR=$(dirname $0)

${THIS_DIR}/pg_restore.sh
${THIS_DIR}/fs_restore.sh
