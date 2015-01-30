correct_version_node="v0.11.15"
correct_version_python="2.7.3"
correct_version_ruby="1.9.3"
correct_version_java="1.7"

current_version_node=`node -v`
current_version_python=`python -V 2>&1 | awk -F 'Python ' '{print $2}' | head -c5`
current_version_ruby=`ruby -v 2>&1 | awk -F 'ruby ' '{print $2}' | head -c5`
current_version_java=`java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | head -c3`

check_version_consistency() {
    name=$1
    current_version=$2
    correct_version=$3

    if [ "$current_version" = "$correct_version" ]; then
        echo "Version of $name is correct. $correct_version"
    else
        echo "Version of $name is incorrect. $current_version=$correct_version"
        exit 1
    fi
}

check_version_consistency "node" $current_version_node $correct_version_node
check_version_consistency "python" $current_version_python $correct_version_python
check_version_consistency "ruby" $current_version_ruby $correct_version_ruby
check_version_consistency "java" $current_version_java $correct_version_java

check_newrelic_installation() {
    language=$1
    output_text=$2

    case "$output_text" in
    *newrelic*) echo "Newrelic installed for $language" ;;
    *      ) echo "Newrelic not installed for $language"; exit 1 ;;
    esac
}

check_newrelic_installation "ruby" `gem list | grep newrelic`
check_newrelic_installation "python" `pip freeze | grep newrelic`

exit 0
