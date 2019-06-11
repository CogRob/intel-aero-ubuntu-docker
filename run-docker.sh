systemctl stop mavlink-router
systemctl stop csd
if [ ! -z $DISPLAY ]; then
    XAUTH=/tmp/.docker.xauth
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    DISPOPTS="-e DISPLAY=$DISPLAY \
       -e XAUTHORITY=$XAUTH \
       -v $XAUTH:$XAUTH \
       -v /tmp/.X11-unix:/tmp/.X11-unix"
fi
if [ -f /usr/bin/nvidia-docker ]; then
    NVIDIAOPTS="--runtime nvidia";
fi
docker run -it   --rm  \
       -e TERM \
       -v /etc/localtime:/etc/localtime:ro \
       -v /mnt/nvme/root/:/mnt/nvme/root \
       --workdir /mnt/nvme/root/catkin_ws \
       -v /lib/systemd/system/avahi-daemon.socket:/lib/systemd/system/avahi-daemon.socket \
       -v /dev/:/dev/ \
       $DISPOPTS $NVIDIAOPTS \
       --privileged \
       --net host \
       --name intel-aero-ubuntu \
       --workdir $(pwd) \
       --security-opt seccomp=unconfined  intel-aero-ubuntu bash
