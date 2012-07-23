<?php

require_once dirname(__FILE__) . "/lib/S3.php";

$payload = getPayload();

// Download image.
$raw_image_content = file_get_contents($payload->image_url);

// Create a test source image for this example.
$im = imagecreatefromstring($raw_image_content);

// Any processing you want - resizing, adding watermark etc.
$text_color = imagecolorallocate($im, 10, 10, 10);
$font = dirname(__FILE__)."/font/Ubuntu-R.ttf";
imagettftext($im, 36, 0, 10, 49, $text_color, $font, $payload->text);

// Output jpeg (or any other chosen) & set quality.
$output_file = dirname(__FILE__)."/output.jpg";
imagejpeg($im, $output_file, 95);



// Upload image.
$s3 = new S3($payload->s3->access_key, $payload->s3->secret_key);
$bucket = $payload->s3->bucket;
$upload_image_name = "irontest.jpg";

if ($s3->putObjectFile($output_file, $bucket, $upload_image_name, S3::ACL_PUBLIC_READ)) {
    echo "Image uploaded successfully!\n";
    echo "View your image at https://$bucket.s3.amazonaws.com/$upload_image_name";
}else{
    echo "File not uploaded!";
}

// Get the contents of our bucket
#$contents = $s3->getBucket($bucket);
#echo "S3::getBucket(): Files in bucket {$bucket}: ".print_r($contents, 1);
