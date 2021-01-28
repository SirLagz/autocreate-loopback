#!/bin/bash
OLDIFS=$IFS
IFS=$'\n'
FILE=$(readlink -f $1)
echo "Attempting to automatically create loop devices for file: $FILE"
OUTPUT=$(parted $FILE --script unit b \ print)
LINES=$(echo "$OUTPUT" | wc -l)
STARTLINE=$(echo "$OUTPUT" | grep -n Number | awk -F ':' ' { print $1 } ')
TAILLINE=$(echo $LINES-$STARTLINE | bc)
HDDDATA=$(echo "$OUTPUT" | tail -n $TAILLINE | grep -v extended)
for x in $HDDDATA; do
    OFFSET=$(echo $x | awk -F ' ' ' { print $2 } ')
    OFFSET=${OFFSET/B/}
    losetup -f -o $OFFSET $FILE
done
echo "Loopback devices setup"
losetup -a
echo "To remove loopback devices, run losetup -D"
IFS=$OLDIFS
