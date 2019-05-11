source setup-ros.sh
roscore &
sleep 5
roslaunch realsense_camera r200_nodelet_rgbd.launch &
sleep 5
rosrun mavros mavros_node _fcu_url:=tcp://127.0.0.1:5760 _system_id:=2 &
