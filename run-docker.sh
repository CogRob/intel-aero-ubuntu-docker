docker run -it   --rm  \
       -e TERM \
       -v /etc/localtime:/etc/localtime:ro \
       -v /data/cogrob/:/data/cogrob/ \
       --privileged \
       --net host \
       --security-opt seccomp=unconfined  intel-aero-ubuntu  bash
