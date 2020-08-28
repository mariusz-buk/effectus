#!/bin/bash

mp="$HOME/Programs/effectus/bin/linux64/mp"
mads="$HOME/Programs/effectus/bin/linux64/mads"
base="$HOME/Programs/effectus/base"
effectus="$HOME/Programs/effectus/bin/linux64/effectus"

if [ -z "$1" ]; then
  echo -e "\nPlease call '$0 <argument>' to run this command!\n"
  exit 1
fi

$effectus -t $1

name=${1::-4}

if [ -f $name.pas ]; then
  [ ! -d "output" ] && mkdir output
  mv $name.pas output/
  $mp output/$name.pas -o
else
  exit 1
fi

if [ -f output/$name.a65 ]; then
  $mads output/$name.a65 -x -i:$base -o:output/$name.xex
else
  exit 1
fi

if [ ! -z "$2" ]; then
  atari800 output/$name.xex
fi
