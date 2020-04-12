#!/bin/sh

echo "readSmaprtData"

DRIVES=(`smartctl --scan | cut -d" " -f1`)


for drive in "${DRIVES[@]}" 
do
	echo "drivname:$drive"
done
