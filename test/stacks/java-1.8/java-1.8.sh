correct_version="1.8"
current_version=`java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | head -c3`

if [ "$current_version" = "$correct_version" ]; then
echo "correct version $correct_version"
exit 0
else
echo "incorrect version $current_version"
exit 1
fi
