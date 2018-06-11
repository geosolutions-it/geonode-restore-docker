GeoNode restore container
=========================


This repo contains docker build config for restore container to be used along with `geonode-generic` stack

Usage
-----


This container is provided to perform restore of backup data produced by `geonode-backup` container/`backup` service in geonode-generic stack.

Restore container uses the same volumes as backup, and will restore latest backup data found.

**Note:** restored stack should have the same name as stack on which backup was performed.

In order to use restore, following conditions must be met:
* Ensure stack on which data is restored has name is the same as one from which backup is used
* Ensure you have stack created and running, so all volumes are created
* Ensure backup is copied to dbbackup volume (usually in `/var/lib/docker/volumes/$geonode-generic-stack-name_dbbackups_$random../` dir)
* Ensure that only backup you want to restore is present in backup data, or it’s the latest available backup you want to restore.

To restore data, perform following steps:
* Ensure you have backup from stack in persistent location
* Start new stack with the same name as one from which backup is used
* Copy data into backup volume. Mind that paths should be preserved.
* Ensure there’s no `fs/$tstamp/data-$tstamp.tar.gz.marker` nor `pg/$tstamp/pg_dumpall-$tstamp.gz.marker` files in backup data.
* Stop django and geoserver containers.
* Start restore container and wait for it to stop.
* Start django and geoserver containers.

When restore container processes backup data, it will leave marker file in the path. Marker file is a file with name of data file from backup with `.marker` suffix, for example:
`/mnt/volumes/backups/geonode-generic/pg/20180508/pg_dumpall-2018_05_08_0202_01.gz` will have `/mnt/volumes/backups/geonode-generic/pg/20180508/pg_dumpall-2018_05_08_0202_01.gz.marker` file accompanying if it was restored. If marker file will be removed, restore container may reprocess it in next run.

If no usable backup data was found or there's a marker file on latest backup available, restore will not perform any operation.

Restore container requires several elemnts to work correctly:
 * persistent storages:
   * GeoServer data in `/mnt/volumes/data/`
   * GeoNode statics and uploads in `/mnt/volumes/statics/`
   * backups storage in `/mnt/volumes/backups/`

 * environment variables:
   * `RANCHER_STACK` - name of stack in which container is run
   * `RANCHER_ENV` - name of environment in which stack is run
   * `PGUSER`, `PGHOST`, `PGPASSWORD`, `PGOPTIONS` - postgresql client connection parameters (`PGUSER` and `PGHOST` should be enough in base scenario)
   * `TARGET_DIR` - optional, alternative base path for backups storage
