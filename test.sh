#!/bin/bash

i="0"
while [ true ]
do

    ./start.sh 
    RET=$?
    if [[ "${RET}" = "0" ]]; then
      echo "done"
      exit 0
    fi

    i=$[$i + 1]
    if [[ "$i" = "10" ]]; then
      echo "failed 10 times :-("
      exit 1
    fi

    echo -n "sleeping for 60 minutes after iteration $i..."  # to avoid ratelimit troubles
    j="0"
    while [ $j -lt 60 ]
    do
      echo -n "."
      j=$[$j + 1]
      sleep 60
    done
    echo ""
    echo ""
    
done
