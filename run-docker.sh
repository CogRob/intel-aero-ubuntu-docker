systemctl stop mavlink-router
systemctl stop csd
systemctl stop avahi-daemon
docker run -it   --rm  \
       -e TERM \
       -v /etc/localtime:/etc/localtime:ro \
       -v /data/cogrob/:/data/cogrob/ \
       -v /lib/systemd/system/avahi-daemon.socket:/lib/systemd/system/avahi-daemon.socket \
       --privileged \
       --net host \
       --security-opt seccomp=unconfined  intel-aero-ubuntu  bash
