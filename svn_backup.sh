#!/bin/bash

SERVER_IP=192.168.2.4

#check for root user
if [[ $EUID -ne 0 ]] ; then

   echo "Script must be excuted  as root user" 2>&1
   exit 1

else
#check availability of the svn server
   ping -c1 $SERVER_IP > /dev/null
   if [ $? -eq 0 ] ; then

#Backup storage directory settings

BACKUP_BASE_LOCATION="/var/repos_backups/svn_repos_backups"

BACKUP_LOG_LOCATION="$BACKUP_BASE_LOCATION/logs"

SCRIPT_EXECUTION_LOGS="$BACKUP_LOG_LOCATION/svn_backup_status.log"

SVN_DUMP_NAME="svn_repo_dump_$(date +"%Y-%m-%d-%T").dump"

#Backup retention configuration 

DAILY_RETENSIONS=2

WEEKLY_RETENSIONS=2

DAILY_DEST="$BACKUP_BASE_LOCATION/Daily"

WEEK_DEST="$BACKUP_BASE_LOCATION/Weekly"

CURRENT_DAY=$(date +%A)

#Creating necessary directories
mkdir -p $BACKUP_BASE_LOCATION  
mkdir -p $DAILY_DEST 
mkdir -p $WEEK_DEST 
mkdir -p $BACKUP_LOG_LOCATION

#Backup rotation logic based on timestamp

function rotate_backups_using_timestamp {

if [ $CURRENT_DAY != "Friday" ] ; then

find $1 -maxdepth 1 -mtime +$DAILY_RETENSIONS -type f -exec rm -rv {} \;

else

retension=$(( $WEEKLY_RETENSIONS * 7 ))


find $1 -maxdepth 1 -mtime +$retension -type f -delete

fi

}

#Backup rotation logic based on version

function rotate_backups {
echo 'In Backup Rotation Logic' >>  $SCRIPT_EXECUTION_LOGS
if [ $CURRENT_DAY != "Friday" ] ; then

sorted_directory_data=(`ls $DAILY_DEST | cut -f 4 -d "_" |cut -f 1 -d "." |sort -V`)

if [ ${#sorted_directory_data[@]} -gt $DAILY_RETENSIONS ] ; then
echo 'Old Dumps Identified' >>  $SCRIPT_EXECUTION_LOGS
echo 'Dump to be deleted' >>  $SCRIPT_EXECUTION_LOGS
echo ${sorted_directory_data[0]} >> $SCRIPT_EXECUTION_LOGS
#echo ${sorted_directory_data[${#sorted_directory_data[@]}-1]}
#echo `find $WEEK_DEST -type f -regex '\^*_${sorted_directory_data[0]}.dump.gz$'`
rm $DAILY_DEST/`ls $DAILY_DEST | grep ${sorted_directory_data[0]}`
echo 'Sucessfully dump rotated' >>  $SCRIPT_EXECUTION_LOGS

fi
else
sorted_directory_data=(`ls $WEEK_DEST | cut -f 4 -d "_" |cut -f 1 -d "." |sort -V`)

if [ ${#sorted_directory_data[@]} -gt $WEEKLY_RETENSIONS ] ; then
echo 'Old Dumps Identified' >>  $SCRIPT_EXECUTION_LOGS
echo 'Dump to be deleted' >>  $SCRIPT_EXECUTION_LOGS
#echo ${sorted_directory_data[0] >> $SCRIPT_EXECUTION_LOGS
#echo ${sorted_directory_data[${#sorted_directory_data[@]}-1]} >> $SCRIPT_EXECUTION_LOGS
echo ${sorted_directory_data[0]} >> $SCRIPT_EXECUTION_LOGS
#echo `find $WEEK_DEST -type f -regex '\^*_${sorted_directory_data[0]}.dump.gz$'`
rm $WEEK_DEST/`ls $WEEK_DEST | grep ${sorted_directory_data[0]}`
echo 'Sucessfully dump rotated' >>  $SCRIPT_EXECUTION_LOGS

fi
fi
#return 1
}
#svn dump logic
echo "-----------------------------------------------status on $(date)------------------------------------" >> $SCRIPT_EXECUTION_LOGS
if [ $CURRENT_DAY != "Friday" ] ; then

  destination=$DAILY_DEST
  ssh root@$SERVER_IP "svnadmin dump /var/www/svn/greenbuds" >  "$destination/$SVN_DUMP_NAME" 2>> "$SCRIPT_EXECUTION_LOGS" 
# echo "${PIPESTATUS[0]}"
  if [ $? -ne 0 ] ; then
   echo 'svn  dumping failed' >>  $SCRIPT_EXECUTION_LOGS
   rm "$destination/$SVN_DUMP_NAME"
   exit 1
  else
    gzip -9 "$destination/$SVN_DUMP_NAME" && rotate_backups 
    #rotate_backups
fi
else

  destination=$WEEK_DEST
  ssh root@$SERVER_IP "svnadmin dump /var/www/svn/greenbuds" > "$destination/$SVN_DUMP_NAME" 2>> "$SCRIPT_EXECUTION_LOGS"
   if [ $? -ne 0 ] ; then
   echo 'svn  dumping failed' >>  $SCRIPT_EXECUTION_LOGS
   rm "$destination/$SVN_DUMP_NAME"
exit 1
  else
    gzip -9 "$destination/$SVN_DUMP_NAME" && rotate_backups 
    #rotate_backups
fi


fi
echo '----------------------------------------------------------------------------------------------------' >> $SCRIPT_EXECUTION_LOGS

else
   echo "server not reachable" 2>&1

fi
fi

