<?php
	
// get ffmpeg version
exec('ffmpeg -version 2>&1', $output);
echo "FFmpeg version: {$output}\n";

$output_file_name = dirname(__FILE__)."/output.mp4";

$frames_list = dirname(__FILE__)."/frames/Frame%d.gif";

// encode video from frames list
$command_line = "ffmpeg -f image2 -i $frames_list $output_file_name 2>&1";
echo "Command line: $command_line\n";
exec($command_line, $output);
print_r($output);

if (file_exists($output_file_name)){

    $file_size = filesize($output_file_name);

    echo "File: $output_file_name \n";
    echo "Size: ".round($file_size/1024, 1)." Kb\n";
}else{
    echo "File not found!\n";
}

