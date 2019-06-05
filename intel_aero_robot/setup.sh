export ROSIFACE=wlp1s0
export ROS_IP=$(ifconfig wlp1s0 | grep 'inet addr:' | sed -e 's/.*inet addr://' | sed -e 's/ Bcast:.*//')
parent=${REALSENSE_ROS_WS}/devel/setup.bash
[ -f "$parent" ] && . "$parent"
PARENTDIR=$(cd $(dirname $0)/../; pwd)
export ROS_PACKAGE_PATH=$PARENTDIR:$ROS_PACKAGE_PATH
export VISODOM=t265
