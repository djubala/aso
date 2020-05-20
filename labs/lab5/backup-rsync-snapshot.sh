#!/bin/bash
# ----------------------------------------------------------------------
# mikes handy rotating-filesystem-snapshot utility
# http://www.mikerubel.org/computers/rsync_snapshots
# Modified by Mauricio Alvarez: http://people.ac.upc.edu/alvarez
# ----------------------------------------------------------------------

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;

MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/usr/bin/touch;

RSYNC=/usr/bin/rsync;


# ------------- file locations -----------------------------------------

MOUNT_DEVICE=/dev/sda8;
SNAPSHOT_MOUNTPOINT=/backup;
SNAPSHOT_DIR=snapshots
EXCLUDES=exclude.txt
BACKUPDIR=/root/


# ------------- the script itself --------------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

# attempt to remount the RW mount point as RW; else abort
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_MOUNTPOINT ;
if (( $? )); then
{
	$ECHO "snapshot: could not remount $SNAPSHOT_MOUNTPOINT readwrite";
	exit;
}
fi;


# rotating snapshots of /$SNAPSHOT_DIR (fixme: this should be more general)



# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.5 ] ; then			\
$RM -rf $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.5 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.4 ] ; then			\
$MV $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.4 $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.5 ;	\
fi;

if [ -d $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.3 ] ; then			\
$MV $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.3 $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.4 ;	\
fi;

if [ -d $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.2 ] ; then			\
$MV $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.2 $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.3 ;	\
fi;

if [ -d $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.1 ] ; then			\
$MV $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.1 $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.2 ;	\
fi;

if [ -d $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.0 ] ; then			\
$MV $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.0 $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.1 ;
fi;

# step 3: rsync from the system into the latest snapshot (notice that
# rsync behaves like cp --remove-destination by default, so the destination
# is unlinked first.  If it were not so, this would copy over the other
# snapshot(s) too!
$RSYNC								\
	-va --delete --delete-excluded				\
	--exclude-from="$EXCLUDES"				\
	--link-dest=$SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.1  \
	$BACKUPDIR  $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.0 ;

# step 5: update the mtime of daily.0 to reflect the snapshot time
$TOUCH $SNAPSHOT_MOUNTPOINT/$SNAPSHOT_DIR/daily.0 ;

# and thats it for $SNAPSHOT_DIR.

# now remount the RW snapshot mountpoint as readonly

$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_MOUNTPOINT ;
if (( $? )); then
{
	$ECHO "snapshot: could not remount $SNAPSHOT_MOUNTPOINT readonly";
	exit;
} fi;


