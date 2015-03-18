correct_version="2.0.0"
current_version=`phantomjs -v 2>&1 | head -n 1 | awk -F ' ' '{print $1}' | head -c6`

if [ "$current_version" = "$correct_version" ]; then
    echo "Version of Phantomjs is correct. $correct_version"
    exit 0
else
    echo "Version of Phantomjs is incorrect. $current_version=$correct_version"
    exit 1
fi