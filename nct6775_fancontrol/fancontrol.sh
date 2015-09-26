#!/bin/bash

#A simple script to set a fixed temperature to pwm map to all fans.

#Smart fan mode.
MODE_SMART_FAN_IV=5
#Make sure this is correct! We don't want to control a video card or anything.
SENSOR_DIR="/sys/class/hwmon/hwmon0"
#The fans to control. I skip 2 as it's a pump.
PWM_DEVICES=(1 3 4 5)

#Enable smart fan control.
for DEVICE in "${PWM_DEVICES[@]}"
do
	PATH="$SENSOR_DIR/pwm${DEVICE}_enable"
	echo $MODE_SMART_FAN_IV > $PATH
done

#Sensitive temperature to pwms. 
#My fans stall below 90 and I think 255 is the maximum for most pwm controllers.
PWM_TEMPS=(32000 35000 40000 50000 60000)
PWM_LEVELS=(0 115 150 185 255)

#For each device.
for DEVICE in "${PWM_DEVICES[@]}"
do
	#For each temperature.
	INDEX=1
	for TEMP in "${PWM_TEMPS[@]}"
	do
		PATH="$SENSOR_DIR/pwm${DEVICE}_auto_point${INDEX}_temp"
		echo $TEMP > $PATH
		INDEX=$(($INDEX + 1))
	done

	#For each pwm.
	INDEX=1
	for TEMP in "${PWM_LEVELS[@]}"
	do
		PATH="$SENSOR_DIR/pwm${DEVICE}_auto_point${INDEX}_pwm"
		echo $TEMP > $PATH
		INDEX=$(($INDEX + 1))
	done
done

