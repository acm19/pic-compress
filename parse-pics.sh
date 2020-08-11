#!/bin/bash

if [ $# != 2 ]; then
  echo "Correct usage $0 SOURCE_DIR TARGET_DIR"
  exit 1
fi

if [ ! -d $1 ]; then
  echo "SOURCE_DIR is not a valid directory"
  exit 1
fi

if [ ! -d $2 ]; then
  echo "TARGET_DIR is not a valid directory"
  exit 1
fi

RATE=${RATE:-50}
source_dir=${1%/}
target_dir=${2%/}
tmp_target=$target_dir/tmp_image

mkdir $tmp_target
jpegoptim -m$RATE -p -d $tmp_target $source_dir/*.JPG

for i in $tmp_target/*.JPG; do
  pic_date=`stat -c %y $i | awk '{print $1}'`
  timestamp_without_timezone=`eval date -d '$pic_date' +%s`
  dir_name=`LC_ALL=en_US.UTF-8; printf "%(%Y %m %B %d)T\n" $timestamp_without_timezone`
  mkdir -p "$target_dir/$dir_name"
  mv "$i" "$target_dir/$dir_name"
done

rm -rf $tmp_target
