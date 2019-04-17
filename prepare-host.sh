
export TZ=America/Los_Angeles
export DEBIAN_FRONTEND=noninteractive
# make sure sudo is installed to be able to give user sudo access in docker
apt-get update \
 && apt-get install -y \
    apt-transport-https \
    build-essential \
    locales \
    sudo \
    wget

### Instructions to install Ubuntu 16.04 on intel-aero ###
# Instructions from https://github.com/intel-aero/meta-intel-aero/wiki/90-(References)-OS-user-Installation

echo 'deb https://download.01.org/aero/deb xenial main' | sudo tee /etc/apt/sources.list.d/intel-aero.list \
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
 

mkdir -p /boot/grub && touch /etc/default/grub && update-grub -y
pip install pymavlink
mkdir -p /etc/acpi/
apt-get -y update && apt-get install -y --reinstall aero-system


sed -ri -e "s#/dev/ttyS[0-9]#/dev/ttyS4#" /usr/sbin/aerofc-update.sh
sed -ri -e "s#/dev/ttyS[0-9]#/dev/ttyS4#" /etc/mavlink-router/main.conf
sed -ri -e "s#/tty/ttyS[0-9]#/tty/ttyS4#" /lib/systemd/system/mavlink-router.service

mkdir -p /etc/mavlink-ruter/config.d
echo '\n\
[UdpEndpoint wifi]\n\
Mode = Normal\n\
Address = 192.168.1.147\n\
\n'\
> /etc/mavlink-router/config.d/qgc.conf
systemctl restart mavlink-router

aero-get-version.py

# aero-bios-update && reboot

aero-get-version.py


aero-get-version.py

cd /etc/aerofc/px4/ \
   && aerofc-update.sh nuttx-aerofc-v1-default.px4

aero-get-version.py

cd /etc/aerofc/ardupilot/ \
   && aerofc-update.sh arducopter-aerofc-v1.px4

aero-get-version.py

## jam -aprogram /etc/fpga/aero-rtf.jam
## cd /tmp \
##     && apt-get -y install git libusb-1.0-0-dev pkg-config libgtk-3-dev libglfw3-dev cmake \
##     && git clone -b legacy --single-branch https://github.com/IntelRealSense/librealsense.git \
##     && cd librealsense \
##     && mkdir build && cd build \
##     && cmake ../ -DBUILD_EXAMPLES=true -DBUILD_GRAPHICAL_EXAMPLES=true \
##     && make \
##     && make install


### End of Instructions to install Ubuntu 16.04 on intel-aero ###
