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

mkdir "$tmp_target"

for i in $source_dir/*/; do
  prefix=$(echo "$i" | awk -F'/' '{print $(NF-1)}')
  find $i -type f -name *.MOV -o -name *.JPG \
   | awk -v prefix=$prefix -v dest=$tmp_target -F'/' '{system("cp -a " $0 " " dest "/" prefix "-" $NF)}'
done

jpegoptim -m$RATE -p $tmp_target/*

for i in $tmp_target/*; do
  pic_date=$(stat -c %y $i | awk '{print $1}')
  timestamp_without_timezone=$(eval date -d '$pic_date' +%s)
  dir_name=$(LC_ALL=en_US.UTF-8; printf "%(%Y %m %B %d)T\n" $timestamp_without_timezone)
  mkdir -p "$target_dir/$dir_name"
  mv "$i" "$target_dir/$dir_name"
done

rm -rf $tmp_target

for i in $target_dir/*/; do
  find "$i" -name *.MOV | grep . > /dev/null && mkdir -p "$i"videos && mv "$i"*.MOV "$i"videos
  pics_name=$(echo "$i" | awk -F'/' '{print $2}' | awk '{print $1 "_" $2 "_" $3 "_" $4'})
  n=1; for f in "$i"*.JPG; do mv "$f" "$(printf "%s%s_%05i.jpg" "$i" "$pics_name" "$n")"; ((n++)); done
done

echo "Files in original directory $(find $source_dir -type f | wc -l)"
echo "Files in compressed directory $(find $target_dir -type f | wc -l)"
