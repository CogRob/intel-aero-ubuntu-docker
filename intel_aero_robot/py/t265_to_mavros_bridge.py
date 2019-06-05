#!/usr/bin/env python
import rospy
from geometry_msgs.msg import PoseStamped, PoseWithCovarianceStamped, TwistStamped
from nav_msgs.msg import Odometry
from functools import partial


def extract_pose_cov_from_odom(odom_msg):
    pose_stamped = PoseWithCovarianceStamped()
    pose_stamped.header.stamp = odom_msg.header.stamp
    pose_stamped.header.frame_id = odom_msg.header.frame_id
    pose_stamped.pose = odom_msg.pose
    return pose_stamped

def extract_pose_from_odom(odom_msg):
    pose_stamped = PoseStamped()
    pose_stamped.header.stamp = odom_msg.header.stamp
    pose_stamped.header.frame_id = odom_msg.header.frame_id
    pose_stamped.pose = odom_msg.pose.pose
    return pose_stamped


def extract_twist_from_odom(odom_msg):
    twist_stamped = TwistStamped()
    twist_stamped.header.stamp = odom_msg.header.stamp
    twist_stamped.header.frame_id = odom_msg.header.frame_id
    twist_stamped.twist = odom_msg.twist.twist
    return twist_stamped


def convert_odom_to_pose_twist(odom_msg):
    return [f(odom_msg)
            for f in (extract_pose_from_odom,)]

def publish_pose_twist_from_odom(publishers, odom_msg):
    for pub, msg in zip(publishers, convert_odom_to_pose_twist(odom_msg)):
        pub.publish(msg)


def conversion_node(intopic='/camera/odom/sample',
                    intopic_type = Odometry,
                    outtopics=['/mavros/vision_pose/pose'],
                    outtopics_type = [PoseStamped],
                    publisher=publish_pose_twist_from_odom,
                    node_name='converter'):
    rospy.init_node(node_name, anonymous=True)
    publisher = partial(
        publisher,
        [rospy.Publisher(otopic, otype, queue_size=10)
         for otopic, otype in zip(outtopics, outtopics_type)])

    rospy.Subscriber(intopic, intopic_type, publisher)
    rospy.spin()


if __name__ == '__main__':
    conversion_node()

