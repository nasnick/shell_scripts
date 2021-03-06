#!/bin/bash -x

# Nick - 03/08/2015
# Find files in /syslog_archive/prod-tdx-01/portal/ directory that are older than 6 months
# 120 days are used in the find command because the backup script finds and backs up files that
# are 2 months old - so need to build a list based on creation date minus 2 months.

SPECIFIC_FOLDER='portal
publish'
REMOTE_FOLDER=/mnt/prod-tdx-01/syslog_archive/prod-tdx-01
BACKUP_FOLDER=/mnt/b2be_backups/tdx-backups/prod-tdx-01/syslog_backups

for i in $SPECIFIC_FOLDER; do
	FILES_TO_BACKUP=$(sudo find $REMOTE_FOLDER/$i -maxdepth 1 -type f -not -name ".*" -ctime -30)
	FILES_TO_REMOVE_FROM_SERVER=$(sudo find $REMOTE_FOLDER/$i -maxdepth 1 -type f -not -name ".*" -ctime +120)

# Check if there are any files to copy and exit if there are none

	if [ -z "$FILES_TO_BACKUP" ] && [ -z "$FILES_TO_REMOVE_FROM_SERVER" ]; then
	  echo "No files to backup or remove... continuing to next folder."
	    continue
	fi
	
# Create list of filesizes to be copied and sort them so they can be compared once copying is complete

sudo find $REMOTE_FOLDER/$i -maxdepth 1 -type f -not -name ".*" -ctime -30 -ls | awk '{print $7,$11}' | sed -e 's/\/mnt\/prod-tdx-01\/syslog_archive\/prod-tdx-01\/'$i'\///g' >> filelistoriginal.txt
cat filelistoriginal.txt | sort  > filelistoriginalsorted.txt

# Copy files

	for FILE in $FILES_TO_BACKUP; do
	    sudo echo cp $FILE $BACKUP_FOLDER/$i
	done

# Build a list of copied file sizes

sudo find $BACKUP_FOLDER/$i -maxdepth 1 -type f -not -name ".*" -ctime  -1 -ls | awk '{print $7,$11}' | sed -e 's/\/mnt\/b2be_backups\/tdx-backups\/prod-tdx-01\/syslog_backups\/'$i'\///g' >> filelistcopied.txt
cat filelistcopied.txt | sort > filelistcopiedsorted.txt

# Make sure that the files are both in the remote and local directories before removing from source

	FILE_DIFF=$(diff -s  filelistoriginalsorted.txt filelistcopiedsorted.txt)

# Check for exit status

DIFF=$(echo "$?")

# If the exit status is '0' then provide success log message
	if [ "$DIFF" = "0" ]; then
		echo "File successfully copied"
	elif [ "$DIFF" != "0" ]; then
		echo "File wasn't successfully copied"
			continue
	fi

#Remove files that are older than 6 months

	echo rm $FILES_TO_REMOVE_FROM_SERVER

	# 	#Remove list of files

 	rm filelist*

#Below no longer needed. On the first run of this job, no files had been copied over so the statements below copied
#all files over to the backup server and then removed files that were older than 6 months. But now this is run monthly
#files are copied over as they are created. Can be used for the first run of other jobs.

# 	if [ "$DIFF" = "0" ]; then
# 	  for REMOTE_FILE in $FILES_TO_REMOVE_FROM_SERVER; do
# 	    sudo echo rm $REMOTE_FILE
# 	  done
# 	elif [ "$DIFF" != "0" ]; then
# 	  echo "Not all files were copied... not removing remote syslog files. Check: $FILE_DIFF"
# 	  echo $FILE_DIFF >> ERROR_LOG_FILE.txt
# 	fi

# 	#Remove list of files

# 	rm filelist*
# done

# if [ -s ERROR_LOG_FILE.txt ]; then
#   rm ERROR_LOG_FILE.txt
#   exit 1
# fi

#---------------------------------------------------------------------------------------------------------------------------

# originally used to build list based on names
##sudo find $REMOTE_FOLDER/$i -maxdepth 1 -type f -not -name ".*" -ctime  +120 | awk -F/ '{print $7}' >> filelistoriginal.txt
#sudo find $BACKUP_FOLDER/$i -maxdepth 1 -type f -not -name ".*" -ctime -1 | awk -F/ '{print $7}' >> filelistcopied.txt