#!/bin/bash
EFFECTUS_HOME="$HOME/Effectus"

if [ -z "$1" ]; then
  echo -e "\nPlease call '$0 <argument>' to run this command!\n"
  exit 1
fi

"${EFFECTUS_HOME}"/effectus $1

name=${1::-4}
filePAS="${name}.pas"
fileAsm="${name}.a65"


if [ -f $filePAS ]; then
  [ ! -d "output" ] && mkdir output
  mv $filePAS output/
  cd output
  "${EFFECTUS_HOME}"/mp $filePAS -o
else
  exit 1
fi

if [ -f $fileAsm ]; then
  "${EFFECTUS_HOME}"/mads $fileAsm -x -i:"${EFFECTUS_HOME}"/base -o:$name.xex
  cd ..
else
  exit 1
fi

if [ ! -z "$2" ]; then
  atari800 output/$name.xex
fi
