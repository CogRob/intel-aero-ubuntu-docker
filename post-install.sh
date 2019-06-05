#!/bin/bash

# aero-bios-update && reboot


# jam -aprogram /etc/fpga/aero-rtf.jam

# TTYID=ttyS$(grep mmio /proc/tty/driver/serial | grep CTS | cut -d: -f 1)
# sed -i -e "s#/dev/ttyS1#/dev/${TTYID}#" /usr/sbin/aerofc-update.sh
# cd /etc/aerofc/px4/ && aerofc-update.sh nuttx-aerofc-v1-default.px4

# cd /etc/aerofc/ardupilot/ && aerofc-update.sh arducopter-aerofc-v1.px4

# sed -i -e "s#/dev/ttyS1#/dev/${TTYID}#" /etc/mavlink-router/main.conf
# sed -i -e "s#/tty/ttyS1#/tty/${TTYID}#" /lib/systemd/system/mavlink-routerd.service
echo 4 > /sys/class/tty/ttyS1/rx_trig_bytes
nohup /usr/bin/mavlink-routerd &> /var/log/mavlink-routerd.log &
nohup /usr/bin/csd &> /var/log/csd.log &
. ${REALSENSE_ROS_WS}/src/intel_aero_robot/setup.sh
roslaunch intel_aero_robot on_robot.launch 2>&1 > /tmp/on_robot_launch.log &
bash
#systemctl restart mavlink-router
