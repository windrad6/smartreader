#!/bin/bash


handle_Temperature () {
	local vendor=$1
	local data=$@
	temp=`grep "Temperature_Celsius" <<< "$data" | tr -s ' ' | cut -d" " -f10 | sed "s/^[ \t]*//"`	
	echo $temp
}




echo "readSmaprtData"

DRIVES=(`smartctl --scan | cut -d" " -f1`)


for drive in "${DRIVES[@]}" 
do
	driveData=`smartctl -a $drive`
	driveFamily=`grep "Model Family" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	driveModel=`grep "Device Model" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	driveSerial=`grep "Serial Number" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	
	#echo $driveName	
	vendor=`cut -d" " -f1 <<< "$driveFamily"`
	if [ $vendor = "Seagate" ]; then
		echo "rerun smartctl"
		driveData=`smartctl -a -v 7,raw48:54 -v 1,raw48:54 $drive`
	fi
	temp=$(handle_Temperature $vendor "$driveData")
	echo "$driveFamily $driveModel $driveSerial $temp"
done
