#!/bin/bash
echo Waiting for Kubernetes to start...
# 如果不存在这个文件夹，就一直等待
  while [ ! -f /root/.kube/config ]
  do
    sleep 1
  done
echo Kubernetes started
# 启动
if [ -f /root/.kube/start ]; then
  /root/.kube/start
fi
