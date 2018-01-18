#!/bin/bash

if [ $# -ne 4 ]; then
  echo "Usage: $0 ip port1 port2 port3"
  exit;
fi

TARGET=$1
shift

# Go through all possible combinations of 3 ports
for PORT1 in "$@"
do
  for PORT2 in "$@"
  do
          for PORT3 in "$@"
          do
              hping3 -S $TARGET -p $PORT1 -c 1 >&2 > /dev/null
              hping3 -S $TARGET -p $PORT2 -c 1 >&2 > /dev/null
              hping3 -S $TARGET -p $PORT3 -c 1 >&2 > /dev/null
          done
  done
done
