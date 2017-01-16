#!/bin/sh
sudo nvidia-docker build -t plenty .
sudo nvidia-docker run -it --name plenty -v ~/proj/plenty:/share:rw plenty 
