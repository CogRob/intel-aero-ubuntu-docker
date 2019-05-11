export ROSIFACE=wlp1s0
export ROS_IP=$(ifconfig wlp1s0 | grep 'inet addr:' | sed -e 's/.*inet addr://' | sed -e 's/ Bcast:.*//')
source /root/code/realsense_ros/devel/setup.bash
