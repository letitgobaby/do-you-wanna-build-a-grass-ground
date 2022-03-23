#!/bin/bash

echo 'hello'

# git_version=`gitt --version`

# if [[ "$git_version" -ne 127 ]]
#   then echo "[ NOTICE ] - You need to install git"; 
#   exit 1
# fi

git_version=`gitt --version` || 'whoami'

if [[ "$git_version" -ne 127 ]]
  then echo "[ NOTICE ] - You need to install git"; 
  exit 1
fi