#!/bin/bash
# 库名称
source="ffmpeg-3.4"
#下载这个库
if [ ! -r $source ];
then
    echo '文件不存在'
else
    rm -rf $source
fi
echo "下载FFmpeg库……"
curl http://ffmpeg.org/releases/${source}.tar.bz2 | tar xj || exit 1
