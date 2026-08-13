#!/bin/bash


#Author: Enam Rab
#Date created: 04/08
#last modified: 22:54 04/08

#Description
#Command substitution demo along with 
#Script to backup directory located on /home/enam-rab/bash_scripting
#to /home/enam-rab/Downloads


msg=$(date +%H:%m:%S)

echo "Hi ${USER^} the current date and time is $msg."
echo "You are inside this date is: $(date)"
echo "--------------------------------------------------"

currentdir=$(pwd)
echo "I will now backup your directory ${currentdir}! to $HOME/Downloads/ "
echo "You are running this script from ${currentdir}"
echo "--------------------------------------------"
echo "                                             "
tar -cf $HOME/Downloads/backup_archive_$(date +"%H:%m:%S").tar /home/enam-rab/bash_scripting  2>/dev/null

echo "---------------------------------------------------- "
echo "Backup completed successfully!................."

exit 0

