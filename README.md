# ROS2 Obstacle Avoidance System (Bash + ROS2)

## About
This project implements a real-time obstacle avoidance system using ROS2 and Bash scripting. It was developed as part of the Linux Basics for Robotics course by The Construct and deployed on a real robot / simulation environment.

The system processes LiDAR data and dynamically controls robot motion using ROS2 topics.
## Environment
- ROS2
- Linux Bash
- The Construct Real Robot Lab
## What Was Provided by The Course
- robot_interface.py
- Course instructions and pseudo-code structure

## What I Implemented
- robot_functions.bash — ROS2 helper functions for reading sensors and sending velocity commands
- obstacle_avoider.bash — full obstacle avoidance algorithm
- robot_statistics.bash — robot statistics display
## How It Works
The obstacle avoider reads 5 LiDAR scan ranges:
left, front left, front, front right, right. Based on which directions are free or blocked relative to a distance threshold, the robot decides to move forward or turn.
### Key Features
- safe_range() — handles inf/nan LiDAR readings (to accommodate for LiDAR sensor limitations)
- move_forward_to_threshold() — calculates safe 
  forward movement distance
- Node ready wait loop — ensures robot interface 
  is running before starting
- Clean shutdown via trap on Ctrl+C
## Credit
- Course: Linux Basics for Robotics
- Platform: The Construct Institute
- robot_interface.py provided by the course
