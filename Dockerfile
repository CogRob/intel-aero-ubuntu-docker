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

RUN mkdir -p /etc/mavlink-router/config.d
RUN echo '\n\
[UdpEndpoint wifi]\n\
Mode = Normal\n\
Address = 192.168.1.147\n\
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
## RUN cd /tmp \
##     && apt-get -y install git libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev cmake \
##     && git clone -b legacy --single-branch https://github.com/IntelRealSense/librealsense.git \
##     && cd librealsense \
##     && mkdir build && cd build \
##     && cmake ../ -DBUILD_EXAMPLES=true -DBUILD_GRAPHICAL_EXAMPLES=true \
##     && make \
##     && make install


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