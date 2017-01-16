#!/bin/sh
sudo docker rm plenty
sudo nvidia-docker run -it --name plenty -v ~/proj/plenty:/share:rw plenty
sudo docker start plenty
sudo docker attach plenty
