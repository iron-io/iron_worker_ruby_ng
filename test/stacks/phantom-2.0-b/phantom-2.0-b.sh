correct_version="2.0.0"
current_version=`phantomjs -v 2>&1 | head -n 1 | awk -F ' ' '{print $1}'`

if [ "$current_version" = "$correct_version" ]; then
    echo "correct version $correct_version"
    exit 0
else
    echo "incorrect version $current_version"
    exit 1
fi