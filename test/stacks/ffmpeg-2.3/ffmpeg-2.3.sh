correct_version_mp4box="0.5.1"
correct_version_ffmpeg="2.3"
correct_version_node="v0.10.29"
correct_version_ruby="1.9.3"
correct_version_java="1.7"

current_version_mp4box=`MP4Box -version 2>&1 | head -n 1 | awk -F 'version ' '{print $2}' | head -c5`
current_version_ffmpeg=`ffmpeg -version 2>&1 | head -n 1 | awk -F 'version ' '{print $2}' | head -c3`
current_version_node=`node -v`
current_version_ruby=`ruby -v 2>&1 | awk -F 'ruby ' '{print $2}' | head -c5`
current_version_java=`java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | head -c3`

check_version_consistency() {
    name=$1
    current_version=$1
    correct_version=$2
    if [ "$current_version" = "$correct_version" ]; then
        echo "Version of $name is correct. $correct_version"
    else
        echo "Version of $name is incorrect. $current_version"
        exit 1
    fi
}
check_version_consistency() "mp4box" $current_version_mp4box $correct_version_mp4box
check_version_consistency() "ffmpeg" $current_version_ffmpeg $correct_version_ffmpeg
check_version_consistency() "node" $current_version_node $correct_version_node
check_version_consistency() "ruby" $current_version_ruby $correct_version_ruby
check_version_consistency() "java" $current_version_java $correct_version_node

exit 0
