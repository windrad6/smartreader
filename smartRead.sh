#!/bin/bash


handle_Type () {
	local vendor=$1
	local attrName=$2
	local data=$3[@]
	temp=`grep $attrName <<< "$data" | sed "s/^[ \t]*//" | tr -s ' ' | cut -d" " -f10 | sed "s/^[ \t]*//"`	
	echo $temp
}




echo "readSmartData"

readarray -t DRIVES <<<`smartctl --scan`

echo -e "Type\t\t\tModel\t\t\tSerial\t\tTemperature\tSeek Err\tRead Err\tUptime" 
for drive in "${DRIVES[@]}" 
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
		#echo "rerun smartctl for Seagate drives"
		driveData=`smartctl -a -v 7,raw48:54 -v 1,raw48:54 $path`
	fi

	temp=$(handle_Type $vendor "Temperature_Celsius" "$driveData")
	seek_err=$(handle_Type $vendor "Seek_Error_Rate" "$driveData")
	read_err=$(handle_Type $vendor "Raw_Read_Error_Rate" "$driveData")
	power_on=$(handle_Type $vendor "Power_On_Hours" "$driveData")

	echo -e "$driveFamily\t$driveModel\t$driveSerial\t$temp\t\t$seek_err\t\t$read_err\t\t$power_on"
done
