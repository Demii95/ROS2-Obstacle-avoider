#! /usr/bin/bash

# include the functions library
source ./robot_functions.bash

# robot statistics

# this is an infinite while loop - use ctrl+c to break
echo "Running Robot Statistics with Bash Script..."
echo "Press Ctrl+C to Terminate..."

# main while loop for naive obstacle avoider
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
while :
do
	# print distance covered since start
	distance=$(get_odom_distance)
	echo "Distance covered: $distance meters"

	# print current direction of robot
	direction=$(get_odom_direction)
	echo "Current direction: $direction"

	# print odom position x, y, z
	odom_x=$(get_odom_position_x)
	odom_y=$(get_odom_position_y)
	odom_z=$(get_odom_position_z)

	echo "Odom Position -> x: $odom_x, y: $odom_y, z: $odom_z"

	# print odom orientation r, p, y
	roll=$(get_odom_orientation_r)
	pitch=$(get_odom_orientation_p)
	yaw=$(get_odom_orientation_y)

	echo "Odom Orientation -> roll: $roll, pitch: $pitch, yaw: $yaw"


done

# End of Code

