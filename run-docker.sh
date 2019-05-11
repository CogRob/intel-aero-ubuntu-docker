sudo systemctl stop mavlink-router
sudo systemctl stop csd
sudo systemctl stop avahi-daemon
if [ ! -z $DISPLAY ]; then
    DISPOPTS="-e DISPLAY=$DISPLAY \
       -e XAUTHORITY=/tmp/.docker.xauth \
       -v /tmp/.docker.xauth:/tmp/.docker.xauth \
       -v /tmp/.X11-unix:/tmp/.X11-unix"
fi
if [ -f /usr/bin/nvidia-docker ]; then
    $NVIDIAOPTS="--runtime nvidia";
fi
docker run -it   --rm  \
       -e TERM \
       -v /etc/localtime:/etc/localtime:ro \
       -v /data/cogrob/:/data/cogrob/ \
       -v /lib/systemd/system/avahi-daemon.socket:/lib/systemd/system/avahi-daemon.socket \
       $DISPOPTS $NVIDIAOPTS \
       --privileged \
       --net host \
       --security-opt seccomp=unconfined  intel-aero-ubuntu  bash
