#!/bin/bash
id=$1
host=$2
zkdir=$3
action=$4
zkctl -zk.myid $id -zk.cfg ${id}@${host}:28881:38881:21811 -log_dir /var/log/vitess/ $action
if  [ $action != 'shutdown' ]; then
  sleep 3
  pid=$(cat $zkdir/zk.pid)
  while kill -0 $(cat $zkdir/zk.pid) ; do
    sleep 5
  done
fi
