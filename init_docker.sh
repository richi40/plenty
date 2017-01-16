#!/bin/sh
sudo docker rm $(sudo docker ps -a | awk '{print $1}' | grep -v CONTAINER)
sudo docker rmi -f $(sudo docker images | awk '{print $3}' | grep -v IMAGE)
