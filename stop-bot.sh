#!/bin/bash
if [ "$(id -u)" = "0" ] ;
then
  echo "WARNING: your running as root"
fi
if [ "$(pgrep node)" != "" ]
then
  echo "Killing previous process... ($(pgrep node))"
  pkill node
fi
