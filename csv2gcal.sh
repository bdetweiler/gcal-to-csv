#!/bin/bash

CSV_FILE=$1
ICS_FILE=$2

DELIMITER=";"


CR=$(printf '\r')
sed "s/\$/$CR/" $CSV_FILE > $CSV_FILE.tmp.csv


echo "BEGIN:VCALENDAR" > $ICS_FILE
echo "PRODID:-//Google Inc//Google Calendar 70.9054//EN" >> $ICS_FILE
echo "VERSION:2.0" >> $ICS_FILE
echo "CALSCALE:GREGORIAN" >> $ICS_FILE
echo "METHOD:PUBLISH" >> $ICS_FILE
echo "X-WR-CALNAME:LR" >> $ICS_FILE
echo "X-WR-TIMEZONE:America/Chicago" >> $ICS_FILE


while IFS=";" read -r dtstart dtend dtstamp uid created description last_modified location sequence status summary transp
do

  # Skip the header
  if [ $dtstart == "DTSTART" ] ; then
    continue;
  fi

  echo "BEGIN:VEVENT" >> $ICS_FILE
  echo "DTSTART;VALUE=DATE:$dtstart" >> $ICS_FILE
  echo "DTEND;VALUE=DATE:$dtend" >> $ICS_FILE
  echo "DTSTAMP:$dtstamp" >> $ICS_FILE
  echo "UID:$uid" >> $ICS_FILE
  echo "CREATED:$created" >> $ICS_FILE
  echo "DESCRIPTION:$description" >> $ICS_FILE
  echo "LAST-MODIFIED:$last_modified" >> $ICS_FILE
  echo "LOCATION:$location" >> $ICS_FILE
  echo "SEQUENCE:$sequence" >> $ICS_FILE
  echo "STATUS:$status" >> $ICS_FILE
  echo "SUMMARY:$summary" >> $ICS_FILE
  echo "TRANSP:$transp" >> $ICS_FILE
  echo "END:VEVENT" >> $ICS_FILE
    
done < $CSV_FILE.tmp.csv

echo "END:VCALENDAR" >> $ICS_FILE

rm $CSV_FILE.tmp.csv
