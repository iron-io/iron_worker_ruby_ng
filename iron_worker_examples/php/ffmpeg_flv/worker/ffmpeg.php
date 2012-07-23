<?php

require_once 'functions.php';

$payload = getPayload();

$input_file = $payload->input_file;
$raw_file = dirname(__FILE__)."/raw.flv";

// Copy incoming big file
echo "Downloading file '$input_file'...\n";
copyfile_chunked($input_file, $raw_file);



# Downscale incoming video to fixed size and bitrate.
# -i input file name
# -ar 22050 Set the audio sampling frequency
# -ab 32k Set audio bitrate
# -f flv Force output file format.
# -b 300k Set video bitrate
# -s Set screen dimensions
$scaled_file = dirname(__FILE__)."/scaled.flv";
$cl = "ffmpeg -i $raw_file -ar 22050 -ab 32k -f flv -b 300k -s 640x360 -y $scaled_file 2>&1";
echo "\nCommand line: $cl\n";
exec($cl, $output);
print_r($output);



# Make jpeg preview.
# -ss 15 Seconds from start.
$img_preview = dirname(__FILE__)."/preview_640x480.jpg";
$cl = "ffmpeg -i $raw_file -an -ss 15 -r 1 -vframes 1 -s 640x480 -f mjpeg -y $img_preview 2>&1";
echo "\nCommand line: $cl\n";
exec($cl, $output);
print_r($output);



# Print output files information.
$files = array($scaled_file, $img_preview);
foreach ($files as $file){
    echo "File: ". basename($file)." - ";

    if (file_exists($file)){
        $file_size = filesize($file);
        echo "Size: ".round($file_size/1024, 1)." Kb\n";
    }else{
        echo "File not found!\n";
    }
}

