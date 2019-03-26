XAUTH=/tmp/.docker.xauth
touch ${XAUTH}
xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
docker run -it   --rm    -v /home/users/vdhiman:/home/users/vdhiman:rw  \
       -e DISPLAY -e TERM \
       -e QT_X11_NO_MITSHM=1 \
       -e XAUTHORITY=$XAUTH -v $XAUTH:$XAUTH \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v /etc/localtime:/etc/localtime:ro \
       --privileged \
       --security-opt seccomp=unconfined  intel-aero-ubuntu
