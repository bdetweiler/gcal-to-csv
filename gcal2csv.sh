#!/bin/bash



NEW_FILE="${1}.tmp.ics"
OUT_FILE="${2}"

tr -d '\r' < $1 > $NEW_FILE

CONTENT=`cat $NEW_FILE | egrep -v "^BEGIN:VCALENDAR|^PRODID|^VERSION|^CALSCALE|^METHOD:PUBLISH|^X-WR"`

CSVLINE=""

DELIMITER=";"

DESCRIPTION_FLAG=false
SUMMARY_FLAG=false

HEADER="DTSTART${DELIMITER}DTEND${DELIMITER}DTSTAMP${DELIMITER}UID${DELIMITER}CREATED${DELIMITER}DESCRIPTION${DELIMITER}LAST_MODIFIED${DELIMITER}LOCATION${DELIMITER}SEQUENCE${DELIMITER}SUMMARY${DELIMITER}TRANSP"

echo "$HEADER" > $OUT_FILE

for line in $CONTENT ; do
  nline=`echo $line | tr '\r' ' ' | sed -e 's/[ \t]*$//'`

  if [ "$nline" == "BEGIN:VEVENT" ] ; then
    CSVLINE=""
  fi
    
  if [[ "$nline" == DTSTART* ]] ; then
    CSVLINE=`echo $line | sed -e 's/^.*://'`
  fi 
    
  if [[ "$nline" == DTEND* ]] ; then
    DTEND=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${DTEND}"
  fi 

  if [[ "$nline" == DTSTAMP* ]] ; then
    DTSTAMP=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${DTSTAMP}"
  fi 

  if [[ "$nline" == UID* ]] ; then
    GUID=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${GUID}"
  fi 
  
  if [[ "$nline" == CREATED* ]] ; then
    CREATED=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${CREATED}"
  fi 
  
  if [ $DESCRIPTION_FLAG == true ] ; then
    if [[ "$nline" == LAST-MODIFIED* ]] ; then
      DESCRIPTION_FLAG=false
    else
      CSVLINE="${CSVLINE} ${nline}"
    fi
  elif [[ "$nline" == DESCRIPTION* ]] ; then
    DESCRIPTION_FLAG=true
    DESCRIPTION=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${DESCRIPTION}"
  fi
    
  if [[ "$nline" == LAST-MODIFIED* ]] ; then
    DESCRIPTION_FLAG=false
    LASTMOD=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${LASTMOD}"
  fi
  
  if [[ "$nline" == LOCATION* ]] ; then
    LOCATION=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${LOCATION}"
  fi

  if [[ "$nline" == SEQUENCE* ]] ; then
    SEQUENCE=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${SEQUENCE}"
  fi
 
  if [ $SUMMARY_FLAG == true ] ; then
    if [[ "$nline" == TRANSP* ]] ; then
      SUMMARY_FLAG=false
    else
      CSVLINE="${CSVLINE} ${nline}"
    fi
  elif [[ "$nline" == SUMMARY* ]] ; then
    SUMMARY_FLAG=true
    SUMMARY=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${SUMMARY}"
  fi

  if [[ "$nline" == TRANSP* ]] ; then
    TRANSP=`echo $line | sed -e 's/^.*://'`
    CSVLINE="${CSVLINE}${DELIMITER}${TRANSP}"
  fi

  if [ "$nline" == "END:VEVENT" ] ; then
    echo "$CSVLINE" >> $OUT_FILE
    CSVLINE=""
  fi
 
done

rm $NEW_FILE
