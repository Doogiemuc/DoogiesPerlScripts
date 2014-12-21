#!/bin/bash
#
# Youtube downloader
#
# Downloads all youtube URLs listed in a file
# @author doogie.de
# @date   November 2014

echo "[worker] start downloading ..."

IN_FILE=/home/doogie/youtube-urls.txt
OUT_DIR=/home/doogie/youtube_vids

mkdir -p $OUT_DIR

youtube-dl --format bestaudio --add-metadata --extract-audio -k --audio-format mp3 --restrict-filenames --batch-file $IN_FILE --output "$OUT_DIR/%(title)s-%(id)s.%(ext)s"

exit 0

# remove all lines from $IN_FILE that were sucessfully downloaded
VIDEO_IDS=`grep -oP '(?<=watch\?v=)[a-zA-Z0-9]+$' $IN_FILE`
for VIDEO_ID in $VIDEO_IDS; do
    echo "looking for $VIDEO_ID"
    ls $OUT_DIR/*$VIDEO_ID.mp3
done; 

exit 0

##################

while read URL; do
  if [[ ! "$URL" =~ ^https?://(www\.)?youtube\.(de|com)/watch\?v=[a-zA-Z0-9]{11} ]]; then continue; fi
  
  #TODO: Do not load a song twice.  Check for file with video_id in $OUT_DIR
      
  echo "[worker] start downloading $URL"
  
  # download audio part of vid only (m4a) and convert it to mp3 audio
  youtube-dl --format bestaudio --add-metadata --extract-audio -k --audio-format mp3 --restrict-filenames $URL
  
  #TODO:  Let youtube-dl handle it with     --batch-file $IN_FILE     
  #       And then purge sucessfull downloads from $in_FILE
  
  
  # check exist status of youtube-dl for success
  if [[ $? -ne 0 ]]; then 
      echo "[worker] ERROR: could not download $URL" 
      continue
  fi  
  echo "[worker] sucessfully downloaded $URL"
  
  # remove downloaded URL from IN_FILE
  case "$1" in
    -p|--purge)
      echo "[worker] purging $URL from $IN_FILE"
      sed -i "\#$URL#d" $IN_FILE
      ;;
  esac
  
  echo 

done <$IN_FILE; 
