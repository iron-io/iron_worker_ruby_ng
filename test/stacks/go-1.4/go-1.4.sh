correct_version="1.4.1"
current_version=`go version 2>&1 | head -n 1 | awk -F ' ' '{print $3}' | tail -c6`

if [ "$current_version" = "$correct_version" ]; then
    echo "correct version $correct_version"
    exit 0
else
    echo "incorrect version $current_version"
    exit 1
fi
