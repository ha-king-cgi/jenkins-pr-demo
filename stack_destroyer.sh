#!/bin/bash

set v

for stacks in $(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --query "StackSummaries[].StackId" | grep "Jenkins-[A-Z]*-[0-9]*-[0-9]*"  | sed s/\"//g | sed s/\,//g); do 
  $time=$(echo $stacks | cut -d'/' -f2 | cut -d'-' -f4)
  $thirty_minutes_ago=$(date -d "30 min ago" +%s)
  if [ "$time" -lt "$thirty_minutes_ago" ]; then 
    aws cloudformation delete-stack --stackId ${stacks}
  fi;
done