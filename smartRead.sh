#!/bin/bash


handle_Type () {
	local vendor=$1
	local attrName=$2
	local data=$@
	temp=`grep "$attrName" <<< "$data" | tr -s ' ' | cut -d" " -f10 | sed "s/^[ \t]*//"`	
	echo $temp
}




echo "readSmartData"


DRIVES=(`smartctl --scan`)


for drive in "${DRIVES[*]}" 
do
	
	path=`cut -d" " -f1 <<< "$drive"`
	devType=`cut -d" " -f6 <<< "$drive"`
	
	driveData=`smartctl -a $path`
	driveFamily=`grep "Model Family" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	driveModel=`grep "Device Model" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	driveSerial=`grep "Serial Number" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	
	#echo $driveName	
	vendor=`cut -d" " -f1 <<< "$driveFamily"`
	
	if [ $devType != "ATA" ]; then
		echo "Device type $devType not supported yet"
		continue
	fi

	if [ $vendor = "Seagate" ]; then
		echo "rerun smartctl for Seagate drives"
		driveData=`smartctl -a -v 7,raw48:54 -v 1,raw48:54 $drive`
	fi

	temp=$(handle_Temperature $vendor "Temperature_Celsius" "$driveData")
	echo "$driveFamily $driveModel $driveSerial $temp"
done
