roscore &
sleep 2
python msg_convert.py &
sleep 2
rostopic echo /camera/odom/sample/pose &
rostopic echo /camera/odom/sample/twist &

echo "+++ Expected Pose +++:
header:
    seq: 1
    stamp:
        secs: 0
        nsecs:         0
    frame_id: 'test_msg_convert'
pose:
    position:
        x: 0.0
        y: 0.0
        z: 0.0
    orientation:
        x: 0.0
        y: 0.0
        z: 1.0
        w: 0.0
"
echo "+++ Expected Twist +++:
header:
    seq: 1
    stamp:
        secs: 0
        nsecs:         0
    frame_id: 'test_msg_convert'
twist:
    linear:
        x: 1.0
        y: 0.0
        z: 0.0
    angular:
        x: 1.0
        y: 0.0
        z: 0.0
"
sleep 2

rostopic pub /camera/odom/sample nav_msgs/Odometry "header:
  seq: 0
  stamp:
    secs: 0
    nsecs: 0
  frame_id: 'test_msg_convert'
child_frame_id: ''
pose:
  pose:
    position: {x: 0.0, y: 0.0, z: 0.0}
    orientation: {x: 0.0, y: 0.0, z: 1.0, w: 0.0}
  covariance: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
twist:
  twist:
    linear: {x: 1.0, y: 0.0, z: 0.0}
    angular: {x: 1.0, y: 0.0, z: 0.0}
  covariance: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0]"
