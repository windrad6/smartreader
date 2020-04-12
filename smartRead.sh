#!/bin/bash


handle_Type () {
	local vendor=$1
	local attrName=$2
	local data=$3[@]
	temp=`grep $attrName <<< "$data" | sed "s/^[ \t]*//" | tr -s ' ' | cut -d" " -f10 | sed "s/^[ \t]*//"`	
	echo $temp
}

handle_singleCol () {
	local vendor=$1
	local attrName=$2
	local data=$3[@]
	temp=`grep $attrName <<< "$data" | sed "s/^[ \t]*//" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	echo $temp
}




echo "readSmartData"

readarray -t DRIVES <<<`smartctl --scan`

printf "%10s %10s %20s %20s %10s %10s %10s %10s %10s\n" "Path" "Vendor" "Model" "Serial" "Temp" "Seek_err" "Read_err" "Power_on" "Status"
for drive in "${DRIVES[@]}" 
do
	path=`cut -d" " -f1 <<< "$drive"`
	devType=`cut -d" " -f6 <<< "$drive"`
	
	driveData=`smartctl -a $path`
	driveFamily=`grep "Model Family:" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	driveVendor=`grep "Vendor:" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	driveModel=`grep "Device Model:" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	

	driveSerial=`grep "Serial Number:" <<< "$driveData" | tr -s ' ' | cut -d":" -f2 | sed "s/^[ \t]*//"`	
	
	#echo $driveName
	if [ -n "$driveVendor" ]; then
		vendor=$driveVendor
	elif [ -z "$driveFamily" ]; then
		vendor=`cut -d" " -f1 <<< "$driveModel"`
	else	
		vendor=`cut -d" " -f1 <<< "$driveFamily"`
	fi

	tmpModel=`cut -d" " -f2 <<< "$driveModel"`
	if [ -n "$tmpModel" ]; then
		driveModel=$tmpModel
	fi
	
	if [ $devType != "ATA" ] && [ $devType != "SCSI" ]; then
		echo "Device type $devType not supported yet"
		continue
	fi

	if [ $vendor == "Seagate" ]; then
		#echo "rerun smartctl for Seagate drives"
		driveData=`smartctl -a -v 7,raw48:54 -v 1,raw48:54 $path`
	fi

	temp=$(handle_Type $vendor "Temperature_Celsius" "$driveData")
	seek_err=$(handle_Type $vendor "Seek_Error_Rate" "$driveData")
	read_err=$(handle_Type $vendor "Raw_Read_Error_Rate" "$driveData")
	power_on=$(handle_Type $vendor "Power_On_Hours" "$driveData")
	status=$(handle_singleCol $vendor "Status:" "$driveData")
	printf "%10s %10s %20s %20s %10s %10s %10s %10s %10s\n" $path "$vendor" "$driveModel" "$driveSerial" "$temp" "$seek_err" "$read_err" "$power_on" "$status"
	#echo -e "$path\t$vendor\t$driveModel\t\t$driveSerial\t$temp\t\t$seek_err\t\t$read_err\t\t$power_on"
done
