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
    wget

### Instructions to install Ubuntu 16.04 on intel-aero ###
# Instructions from https://github.com/intel-aero/meta-intel-aero/wiki/90-(References)-OS-user-Installation

RUN echo 'deb https://download.01.org/aero/deb xenial main' | sudo tee /etc/apt/sources.list.d/intel-aero.list \
    && wget -qO - https://download.01.org/aero/deb/intel-aero-deb.key | sudo apt-key add - \
    && apt-get -y update \
    && apt-get -y upgrade \
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
      v4l-utils
 

RUN mkdir -p /boot/grub && touch /etc/default/grub && update-grub -y
RUN pip install pymavlink
RUN mkdir -p /etc/acpi/
RUN apt-get -y update && apt-get install -y aero-system
RUN apt-get -y purge modemmanager

RUN mkdir -p /etc/mavlink-router/config.d
RUN echo '\n\
[UdpEndpoint wifi]\n\
Mode = Normal\n\
Address = 100.80.226.255\n\
\n'\
> /etc/mavlink-router/config.d/qgc.conf
# RUN systemctl restart mavlink-router

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
### +++++ End of commands for librealsense2 ++++++++

RUN mkdir -p /root/code/realsense_ros \
    && cd /root/code/realsense_ros \
    && git clone -b 2.2.3 https://github.com/IntelRealSense/realsense-ros.git  src \
    && . /opt/ros/kinetic/setup.sh \
    && catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release


RUN apt-get update && apt-get -y install \
    libcholmod3.0.6 libsuitesparse-dev libeigen3-dev libsuitesparse-dev \
    protobuf-compiler libnlopt-dev ros-kinetic-octomap \
    ros-kinetic-octomap-rviz-plugins ros-kinetic-octomap-ros ros-kinetic-sophus

RUN apt-get update && apt-get -y install python-argparse git-core wget zip \
  python-empy qtcreator cmake build-essential genromfs \
  ant protobuf-compiler libeigen3-dev libopencv-dev openjdk-8-jdk openjdk-8-jre \
  clang-3.5 lldb-3.5 python-toml python-numpy python-pip \
  ros-kinetic-gazebo-ros

RUN pip install --upgrade pip \
    && pip install pandas jinja2

RUN cd /root/code \
    && git clone https://github.com/szebedy/autonomous-drone.git \
    && git submodule update --init --recursive \
    && cd /root/code/realsense_ros/src/ \
    && for d in ../../autonomous-drone/src/*; do ln -s ../../autonomous-drone/src/$d; done \
    && cd /root/code/realsense_ros/ \
    && catkin_make

RUN cd /root/code/autonomous-drone/px4 \
   && make posix_sitl_default gazebo

RUN cd /root/code \
    && wget http://rpg.ifi.uzh.ch/svo2/svo_binaries_1604_kinetic.zip 

### End of Instructions to install Ubuntu 16.04 on intel-aero ###

RUN mkdir -p /etc/pulse
RUN echo '\n\
# Connect to the hosts server using the mounted UNIX socket\n\
default-server = unix:/run/user/@(user_id)/pulse/native\n\
\n\
# Prevent a server running in the container\n\
autospawn = no\n\
daemon-binary = /bin/true\n\
\n\
# Prevent the use of shared memory\n\
enable-shm = false\n\
\n'\
> /etc/pulse/client.conf

RUN apt-get update && apt-get -y install x11vnc xvfb mesa-utils usbutils
RUN     mkdir ~/.vnc
RUN     x11vnc -storepasswd 1234 ~/.vnc/passwd

RUN pip install --upgrade pip
# RUN pip install Cython numpy
# RUN pip install pyrealsense
RUN geographiclib-get-geoids egm96-5

COPY systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl
COPY post-install.sh /root/post-install.sh
RUN chmod +x /root/post-install.sh
CMD ["/root/post-install.sh"]

# WORKDIR /data/cogrob/code
