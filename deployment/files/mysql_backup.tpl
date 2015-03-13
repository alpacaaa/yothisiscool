#!/bin/bash -x
#===============================================================================
#
#          FILE: percona-xtrabackup.sh
#
#         USAGE: ./percona-xtrabackup.sh
#
#   DESCRIPTION: Forked from https://gist.github.com/jaygooby/5208373
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: TODO: Integrate into alerting system, Write restore flag until then see http://www.percona.com/doc/percona-xtrabackup/2.1/innobackupex/innobackupex_option_reference.html#cmdoption-innobackupex--decompress
#        AUTHOR: Josh Boon (jcb), josh@hungryfishmedia.com, alwayscurious@joshboon.com
#  ORGANIZATION: Hungry Fish Media, LLC
#       CREATED: 01/30/2014 01:00:22 PM EST
#      REVISION:  1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error
# Put me in cron.daily, cron.hourly or cron.d for your own custom schedule
# Also the file below as least needs options defined Sample:
# ##### Sample /etc/mysql/perconabackup.local.conf ##########
OPTIONS=" -user=root -password={{ dude.mysql_root_db_pass }} --rsync --compress --compress-threads=$(grep -c ^processor /proc/cpuinfo) --parallel=$(grep -c ^processor /proc/cpuinfo)"
EMAIL=changeme@example.com
#
# Running daily? You'll keep 3 daily backups
# Running hourly? You'll keep 3 hourly backups
NUM_BACKUPS_TO_KEEP=${NUM_BACKUPS_TO_KEEP:=3}


# Where you keep your backups
BACKUPDIR=/home/dude/backup/mysql

# path to innobackupex
XTRABACKUP=/usr/bin/innobackupex

# Add any other files you never want to remove
NEVER_DELETE="lost\+found|\.|\.."

# Assuming here your data dir is /var/lib/mysql
DATADIR=/var/lib/mysql
# Setup temp files
EMAILTMP=$(mktemp)
LOGTMP=$(mktemp)
# We like to make sure we have space first
function check_freespace (){
SRC=$1
DST=$2
COMPRESSION=${3:-1}
SRCSIZE=$(du -bs $SRC | awk '{ print $1 }')
DSTSIZE=$(($(stat -f --format="%a*%S" $DST)))
FREESPACE=$(echo "($DSTSIZE*.97)-($SRCSIZE*$COMPRESSION)" | bc -l)
echo We have $(echo "$FREESPACE/1024/1024/1024" | bc -l) GB of space left
# We want precision here so using bc instead of bash.
if [[ $(echo "$FREESPACE < 0" | bc -l) = 1 ]]
then
  echo NOT ENOUGH FREESPACE LEFT
  return 1
fi
}
# We will timestamp ourself so we can log there too.
TIMEDIR=$(date +%F-%H-%M-%S)
# Confirm free space flight check
check_freespace $DATADIR $BACKUPDIR .3 | tee -a $EMAILTMP
# Catch errors above
BACKUPSTATUS=$PIPESTATUS

# Make sure the backup user exists
# GRANT RELOAD, LOCK TABLES, SUPER, REPLICATION CLIENT ON *.* TO 'bkpuser'@'localhost' identified by 'password';
# FLUSH PRIVILEGES;"
# The mysql user able to access all the databases
# Shouldn't need to change these...
BACKUP="$XTRABACKUP --no-timestamp $OPTIONS $BACKUPDIR/$TIMEDIR"
PREV=$(ls -r $BACKUPDIR | tail -n+$((NUM_BACKUPS_TO_KEEP+1)))
# run a backup
START=$(date +%s.%N)
# Only start if preflight checks pass
if [ $BACKUPSTATUS = 0 ]
then
# For big DBs with lots of tables
ulimit -n 100000
        $BACKUP 2>&1 | tee -a $LOGTMP
  BACKUPSTATUS=$PIPESTATUS
fi
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo backup took $DIFF seconds >> $EMAILTMP
if [ $BACKUPSTATUS == 0 ]; then
         echo "The following backup will be deleted if any $BACKUPDIR/$PREV" >> $EMAILTMP
         echo "We estimated compression of 70% We saw an actual compression of $(echo 1-$(du -bs $BACKUPDIR/$TIMEDIR | awk '{ print $1 }')/$(du -bs $DATADIR | awk '{ print $1 }') | bc -l ) of $(du -hs $DATADIR)" >> $EMAILTMP
   mail $EMAIL -s "Mysql backup success on $(hostname -f)" < $EMAILTMP
  mv $LOGTMP $BACKUPDIR/$TIMEDIR/backup.log
        # remove backups you don't want to keep
        cd $BACKUPDIR
        rm -rf $PREV
 #   echo $PREV | xargs -Idir rm -rf $BACKUPDIR/dir
                rm -rf $EMAILTMP
else
# problem with initial backup :(
    tail -n20 $LOGTMP >> $EMAILTMP
                mv $LOGTMP $BACKUPDIR/$TIMEDIR
    mail $EMAIL -s "Mysql backup failed on $(hostname -f)" < $EMAILTMP
                rm -rf $EMAILTMP
fi
