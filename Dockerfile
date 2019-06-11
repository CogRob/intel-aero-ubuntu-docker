FROM ros:kinetic-robot-xenial

ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive
# make sure sudo is installed to be able to give user sudo access in docker
RUN apt-get update \
 && apt-get install -y \
    apt-transport-https \
    build-essential \
    locales \
    sudo \
    wget \
 && apt-get clean

### Instructions to install Ubuntu 16.04 on intel-aero ###
# Instructions from https://github.com/intel-aero/meta-intel-aero/wiki/90-(References)-OS-user-Installation

RUN echo 'deb https://download.01.org/aero/deb xenial main' | sudo tee /etc/apt/sources.list.d/intel-aero.list \
    && wget -qO - https://download.01.org/aero/deb/intel-aero-deb.key | sudo apt-key add - \
    && apt-get -y update \
    && apt-get -y upgrade \
    && mkdir -p /etc/default && touch /etc/default/grub \
    && mkdir -p /boot/grub && touch /boot/grub/menu.lst \
    && mkdir -p /etc/acpi/ \
    && apt-get -y install \
      apt-utils \
      ffmpeg \
      grub \
      gstreamer-1.0 \
      gstreamer1.0-libav \
      gstreamer1.0-plugins-bad \
      gstreamer1.0-plugins-base \
      gstreamer1.0-plugins-good \
      gstreamer1.0-vaapi \
      libgstreamer-plugins-base1.0-dev \
      libgstrtspserver-1.0-dev \
      python-pip \
      v4l-utils \
      aero-system \
 && apt-get clean

RUN pip install pymavlink
RUN apt-get -y purge modemmanager

## RUN systemctl restart mavlink-router

## RUN aero-bios-update && reboot
## 
## RUN jam -aprogram /etc/fpga/aero-rtf.jam
## 
## RUN cd /etc/aerofc/px4/ \
##     && aerofc-update.sh nuttx-aerofc-v1-default.px4
## 


RUN apt-get -y update && \
	apt-get -y install dmidecode psmisc \
    python-pip python-opencv python-opencv-apps python-zbar zbar-tools \
    vim-python-jedi vim-python-jedi vim-nox-py2 \
    geographiclib-tools \
    ros-kinetic-mavros-extras \
    ros-kinetic-mavros \
    ros-kinetic-cv-bridge \
    ros-kinetic-image-transport \
    ros-kinetic-dynamic-reconfigure \
    tmux \
    ntpdate \
    net-tools \
    iputils-ping \
    lsof \
    avahi-daemon \
    git libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev cmake


ARG build_legacy_realsense=
### +++++ Build commands for librealsense legacy ++++++++
RUN [ -z "$build_legacy_realsense" ] \
    || { mkdir /tmp/legacy-librealsense \
    && cd /tmp/legacy-librealsense \
    && apt-get -y install git libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev cmake \
    && git clone -b legacy --single-branch https://github.com/IntelRealSense/librealsense.git \
    && cd librealsense \
    && mkdir build && cd build \
    && cmake ../ -DBUILD_EXAMPLES=false -DBUILD_GRAPHICAL_EXAMPLES=false \
    && make \
    && make install; }
### +++++ End of commands for librealsense legacy ++++++++


ARG build_librealsense2=
### +++++ Build commands for librealsense2 ++++++++
## # Instructions from https://github.com/IntelRealSense/librealsense/blob/master/doc/installation.md#make-ubuntu-up-to-date
## # Skipping the patch step #### bash ./scripts/patch-realsense-ubuntu-lts.sh
RUN [ -z "$build_librealsense2" ] \
    || { mkdir -p /root/code/librealsense2 \
    && cd /root/code/librealsense2 \
    && git clone -b v2.21.0 --single-branch https://github.com/IntelRealSense/librealsense.git \
    && cd librealsense \
    && ln -s /usr/src/linux-headers-4.4.76-aero-1.2 /usr/src/linux-headers-4.4.76-yocto-standard \
    && yes | bash ./scripts/setup_udev_rules.sh \
    && echo 'hid_sensor_custom' | tee -a /etc/modules \
    && mkdir build && cd build \
    && cmake ../ -DBUILD_EXAMPLES=true -DBUILD_GRAPHICAL_EXAMPLES=true \
    && make \
    && make install; }
### +++++ End of commands for librealsense2 ++++++++

### +++++ Distribution install commands for librealsense2 ++++++++
RUN [ ! -z "$build_librealsense2" ] \
    || { apt-get update && apt-get install -y software-properties-common \
    && { apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE; } \
    && add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u \
    && apt-get update && apt-get install -y \
    librealsense2-utils \
    librealsense2-dev \
    librealsense2-dbg; }
### +++++ End of commands for librealsense2 +++++++++++++++++++++++++++++++++++++

ENV REALSENSE_ROS_WS /root/code/realsense_ros
RUN mkdir -p ${REALSENSE_ROS_WS} \
    && cd ${REALSENSE_ROS_WS} \
    && git clone -b 2.2.3 https://github.com/IntelRealSense/realsense-ros.git  src \
    && . /opt/ros/kinetic/setup.sh \
    && rosdep install --from-path src \
    && catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release

ARG build_autonomous_drone=
### +++++ Build commands for autonomous-drone +++++++++++++++++++++++++++++++++++
RUN [ -z "$build_autonomous_drone" ] || { \
      apt-get update && apt-get -y install \
      libcholmod3.0.6 libsuitesparse-dev libeigen3-dev libsuitesparse-dev \
      protobuf-compiler libnlopt-dev ros-kinetic-octomap \
      ros-kinetic-octomap-rviz-plugins ros-kinetic-octomap-ros ros-kinetic-sophus \
      python-argparse git-core wget zip \
      python-empy qtcreator cmake build-essential genromfs \
      ant protobuf-compiler libeigen3-dev libopencv-dev openjdk-8-jdk \
      openjdk-8-jre \
      clang-3.5 lldb-3.5 python-toml python-numpy python-pip \
      ros-kinetic-gazebo-ros \
    && pip install pandas jinja2 \
    && cd /root/code \
    && git clone https://github.com/szebedy/autonomous-drone.git \
    && cd autonomous-drone \
    && git submodule update --init --recursive \
    && cd ${REALSENSE_ROS_WS}/src/ \
    && for d in ../../autonomous-drone/src/*; do ln -s ../../autonomous-drone/src/$d || true; done \
    && cd ${REALSENSE_ROS_WS}/ \
    && . /opt/ros/kinetic/setup.sh \
    && catkin_make \
    && cd /root/code/autonomous-drone/px4 \
    && make posix_sitl_default gazebo \
    && cd /root/code \
    && wget http://rpg.ifi.uzh.ch/svo2/svo_binaries_1604_kinetic.zip; }
### +++++ End of commands for autonomous-drone +++++++++++++++++++++++++++++++++++

RUN apt-get update && apt-get -y install x11vnc xvfb mesa-utils usbutils
RUN     mkdir ~/.vnc
RUN     x11vnc -storepasswd 1234 ~/.vnc/passwd

RUN apt-get update && apt-get -y install tmux vim ssh git ros-kinetic-dynamic-reconfigure

RUN pip install --upgrade pip
# RUN pip install Cython numpy
# RUN pip install pyrealsense
RUN geographiclib-get-geoids egm96-5

COPY intel_aero_robot ${REALSENSE_ROS_WS}/src/intel_aero_robot
COPY systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl
COPY post-install.sh /root/post-install.sh
RUN chmod +x /root/post-install.sh
#CMD ["/root/post-install.sh"]
RUN mkdir -p /boot/grub \
     && touch /boot/grub/menu.lst  \
     && apt-get update && yes | apt-get install -y aero-system tmux vim && apt-get clean
RUN cd /root/code/realsense_ros/ \
	&& . /opt/ros/kinetic/setup.sh \
	&& rosdep install --from-path src
	

# WORKDIR /data/cogrob/code
