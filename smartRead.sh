#!/bin/sh


handle_Temperature () {
	vendor=$1
	data=$2
	echo "temp handle$vendor"
	temperature=`grep "Temperature" <<< "$data" | cut -d" " -f10 | sed "s/^[ \t]*//"`	
}




echo "readSmaprtData"

DRIVES=(`smartctl --scan | cut -d" " -f1`)


for drive in "${DRIVES[@]}" 
do
	driveData=`smartctl -a $drive`
	
	driveName=`grep "Model" <<< "$driveData" | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	
	echo $driveName	
	vendor=`cut -d" " -f1 <<< "$driveName"`

	handle_Temperature $vendor $driveData
done
