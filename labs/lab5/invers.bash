#!/bin/bash

SOURCE_DIR=/root
DEST_DIR=/backup/backup-rsync/

# excludes file: list of files to exclude
EXCLUDES=exclude.txt

# the name of the backup machine
BSERVER=localhost

# the name of the incremental backups directory
# put a date command for: year month day hour minute second
BACKUP_DATE=$(date +%Y%m%d%H%M)

# options for rsync
OPTS="--ignore-errors --delete-excluded --exclude-from=$EXCLUDES \
--delete --backup --backup-dir=$DEST_DIR/$BACKUP_DATE -av"

# now the actual transfer
rsync $OPTS $SOURCE_DIR root@$BSERVER:$DEST_DIR/complet
