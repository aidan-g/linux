#!/bin/bash

#A simple script to set a fixed temperature to pwm map to all fans.

#Ensure sensors are loaded.

echo "Checking configuration.."

SENSOR_NAME="nct6791"
MODULE="nct6775"
LOADED=$(lsmod | grep $MODULE)

if [ -z "$LOADED" ]
then
	echo "Module $MODULE is not loaded, attempting to load it.."
	/sbin/modprobe "$MODULE"
	if [ $? -ne 0 ]
	then
		echo "Failed to load the required module."
		exit 1
	fi
fi

echo "Locating sensors for ${MODULE}.."

SENSOR_DIR=""
for HW_MON in /sys/class/hwmon/hwmon[0-9]
do
	echo "Checking ${HW_MON}.."
	NAME=$(cat "$HW_MON/name")
	if [ "$NAME" != "$SENSOR_NAME" ]
	then
		continue
	fi
	SENSOR_DIR="$HW_MON"
	break
done

if [ -z "$SENSOR_DIR" ]
then
	echo "Failed to locate the correct sensors."
	exit 1
fi

echo "$MODULE sensors found at ${SENSOR_DIR}."

#Smart fan mode.
MODE_SMART_FAN_IV=5
#The fans to control. I skip 2 as it's a pump.
PWM_DEVICES=(1 3 4 5)

#Enable smart fan control.

echo "Enabling smart fan control.."

for DEVICE in "${PWM_DEVICES[@]}"
do
	NODE="$SENSOR_DIR/pwm${DEVICE}_enable"
	echo "Enabling smart fan control for pwm device ${NODE}.."
	echo $MODE_SMART_FAN_IV > $NODE
done

echo "Smart fan control enabled."
echo "Setting temperature points.."

#My fans stall below 90 and I think 255 is the maximum for most pwm controllers.
PWM_TEMPS=(32000 35000 40000 50000 60000)
PWM_LEVELS=(90 115 150 185 255)

#For each device.
for DEVICE in "${PWM_DEVICES[@]}"
do
	echo "Setting temperature points for pwm device ${DEVICE}.."

	#For each temperature.
	INDEX=1
	for TEMP in "${PWM_TEMPS[@]}"
	do
		echo "Setting temperature point $INDEX -> $TEMP for pwm device ${DEVICE}.."
		NODE="$SENSOR_DIR/pwm${DEVICE}_auto_point${INDEX}_temp"
		echo $TEMP > $NODE
		INDEX=$(($INDEX + 1))
	done

	echo "Setting pwm points for pwm device ${DEVICE}.."

	#For each pwm.
	INDEX=1
	for LEVEL in "${PWM_LEVELS[@]}"
	do
		echo "Setting pwm level $INDEX -> $LEVEL for pwm device ${DEVICE}.."
		NODE="$SENSOR_DIR/pwm${DEVICE}_auto_point${INDEX}_pwm"
		echo $LEVEL > $NODE
		INDEX=$(($INDEX + 1))
	done
done

echo "All done."
exit 0
