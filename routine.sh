#!/bin/bash

author='git --no-pager show -s --format="%an"'
build_time='date +%s'
stack_name='Jenkins-${env.BRANCH_NAME}-${build_time}-${author}'
tags='Key=author,Value=${author}'
file='Jenkins-Demo-PR.json'

aws cloudformation create-stack --stack-name ${stack_name} --tags ${tags} --template-body file://${file}

exit 0