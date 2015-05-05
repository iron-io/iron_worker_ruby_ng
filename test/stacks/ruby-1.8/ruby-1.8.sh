correct_version="1.8.7"
current_version=`ruby -v 2>&1 | awk -F 'ruby ' '{print $2}' | head -c 5`

if [ "$current_version" = "$correct_version" ]; then
    echo "OK! Correct version --> $correct_version"
    exit 0
else
    echo "FAIL! Incorrect version --> $current_version"
    exit 1
fi
