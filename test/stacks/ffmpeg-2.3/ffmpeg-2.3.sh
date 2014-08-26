correct_version_mp4box="0.5.1-DEV-rev4065"
correct_version_ffmpeg="0.8.10-6"

current_version_mp4box=`MP4Box -version 2>&1 | head -n 1 | awk -F 'version ' '{print $2}'`
current_version_ffmpeg=`ffmpeg -version 2>&1 | head -n 1 | awk -F 'version ' '{print $2}' | head -c8`

if [ "$current_version_mp4box" = "$correct_version_mp4box" ]; then
    echo "Version of mp4box is correct. $correct_version_mp4box"
else
    echo "Version of mp4box is incorrect. $current_version_mp4box"
    exit 1
fi

if [ "$current_version_ffmpeg" = "$correct_version_ffmpeg" ]; then
    echo "Version of ffmpeg is correct. $correct_version_ffmpeg"
else
    echo "Version of ffmpeg is incorrect. $current_version_ffmpeg"
    exit 1
fi

exit 0