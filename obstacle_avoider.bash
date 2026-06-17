#! /usr/bin/bash

source ./robot_functions.bash

# stop the robot cleanly on Ctrl+C or kill
trap 'set_cmd_vel_linear 0.0; set_cmd_vel_angular 0.0; echo "Stopped."; exit 0' SIGINT SIGTERM

# replace inf/nan LiDAR readings with a safe large value (10 m)
safe_range() {
    local val=$1
    if echo "$val" | grep -qiE '^inf$|^nan$|^-inf$'; then
        echo "10.0"
    else
        echo "$val"
    fi
}

# move forward until (range - threshold) meters have elapsed, then stop
move_forward_to_threshold() {
    local range=$1
    local dist_to_move

    dist_to_move=$(echo "$range - $threshold" | bc -l)
    if [ "$(echo "$dist_to_move > 0" | bc -l)" -eq 1 ]; then
        local time_to_move
        time_to_move=$(echo "scale=2; $dist_to_move / 0.1" | bc -l)
        time_to_move=$(echo "$time_to_move - 0.5" | bc -l)
        if [ "$(echo "$time_to_move > 0" | bc -l)" -eq 1 ]; then
            set_cmd_vel_linear 0.1
            set_cmd_vel_angular 0.0
            sleep "$time_to_move"

        else
            # range is free but too close to move forward safely
            # nudge forward slowly for a fixed short time instead
            set_cmd_vel_linear 0.05
            set_cmd_vel_angular 0.0
            sleep 0.5
        fi
        
    fi
    set_cmd_vel_linear 0.0
}

echo "Running Naive Obstacle Avoider with Bash Script..."
echo "Press Ctrl+C to Terminate..."

echo "Waiting for robot_interface node..."
until ros2 node list | grep -q "/robot_interface"
do
    echo "Node not found, retrying..."
    sleep 1
done
echo "Node ready! Starting obstacle avoider..."

set_cmd_vel_linear 0.000
set_cmd_vel_angular 0.000

threshold=0.350

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
while :
do
    left_range=$(safe_range "$(get_scan_left_ray_range)")
    front_left_range=$(safe_range "$(get_scan_front_left_ray_range)")
    front_range=$(safe_range "$(get_scan_front_ray_range)")
    front_right_range=$(safe_range "$(get_scan_front_right_ray_range)")
    right_range=$(safe_range "$(get_scan_right_ray_range)")

    front_left_free=$(echo "$front_left_range > $threshold" | bc -l)
    front_free=$(echo "$front_range > $threshold" | bc -l)
    front_right_free=$(echo "$front_right_range > $threshold" | bc -l)

    if [ "$front_left_free" -eq 0 ] && [ "$front_free" -eq 0 ] && [ "$front_right_free" -eq 0 ]
    then
        if [ "$(echo "$left_range > $right_range" | bc -l)" -eq 1 ]
        then
            set_cmd_vel_linear 0.0
            set_cmd_vel_angular 0.785398
            sleep 0.5
            set_cmd_vel_angular 0.0
        else
            set_cmd_vel_linear 0.0
            set_cmd_vel_angular -0.785398
            sleep 0.5
            set_cmd_vel_angular 0.0
        fi

    elif [ "$front_left_free" -eq 0 ] && [ "$front_free" -eq 0 ] && [ "$front_right_free" -eq 1 ]
    then
        set_cmd_vel_linear 0.0
        set_cmd_vel_angular -0.785398
        sleep 0.5
        set_cmd_vel_angular 0.0

    elif [ "$front_left_free" -eq 0 ] && [ "$front_free" -eq 1 ] && [ "$front_right_free" -eq 0 ]
    then
        move_forward_to_threshold "$front_range"

    elif [ "$front_left_free" -eq 0 ] && [ "$front_free" -eq 1 ] && [ "$front_right_free" -eq 1 ]
    then
        set_cmd_vel_linear 0.0
        set_cmd_vel_angular -0.785398
        sleep 0.5
        set_cmd_vel_angular 0.0

    elif [ "$front_left_free" -eq 1 ] && [ "$front_free" -eq 0 ] && [ "$front_right_free" -eq 0 ]
    then
        set_cmd_vel_linear 0.0
        set_cmd_vel_angular 0.785398
        sleep 0.5
        set_cmd_vel_angular 0.0

    elif [ "$front_left_free" -eq 1 ] && [ "$front_free" -eq 0 ] && [ "$front_right_free" -eq 1 ]
    then
        if [ "$(echo "$left_range > $right_range" | bc -l)" -eq 1 ]
        then
            set_cmd_vel_linear 0.0
            set_cmd_vel_angular 0.785398
            sleep 0.5
            set_cmd_vel_angular 0.0
        else
            set_cmd_vel_linear 0.0
            set_cmd_vel_angular -0.785398
            sleep 0.5
            set_cmd_vel_angular 0.0
        fi

    elif [ "$front_left_free" -eq 1 ] && [ "$front_free" -eq 1 ] && [ "$front_right_free" -eq 0 ]
    then
        set_cmd_vel_linear 0.0
        set_cmd_vel_angular 0.785398
        sleep 0.7
        set_cmd_vel_angular 0.0

    else
        move_forward_to_threshold "$front_range"
    fi

    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    sleep 0.5
done