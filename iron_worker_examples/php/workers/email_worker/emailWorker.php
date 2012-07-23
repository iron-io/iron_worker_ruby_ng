<?php
include("./lib/IronCore.class.php");
require_once dirname(__FILE__) . "/lib/IronCache.class.php";
require_once dirname(__FILE__) . "/lib/class.phpmailer.php";
require_once dirname(__FILE__) . "/lib/class.smtp.php";

function init_mail($payload)
{
    $mail = new PHPMailer();
    $mail->IsSMTP();
    $mail->SMTPDebug = 0;  // debugging: 1 = errors and messages, 2 = messages only
    $mail->SMTPAuth = true;  // authentication enabled
    $mail->SMTPSecure = 'ssl'; // secure transfer enabled
    $mail->Host = $payload->host;
    $mail->Port = $payload->port;
    $mail->Username = $payload->username;
    $mail->Password = $payload->password;
    return $mail;
}

function send_mail($to, $from, $subject, $body,$mail)
{
    $mail->SetFrom($from, 'Best Company');
    $mail->Subject = $subject;
    $mail->MsgHTML($body);
    $mail->AddAddress($to, "Dear User");
    $mail->Send();
}

function update_message_status($payload, $email)
{
    echo("Updating status\n");
    //Ping your api
     echo("pinging api\n");
     file_get_contents('http://google.com/?email='.urlencode($email));
  if (!empty($payload->token) && !empty($payload->project_id))
  {
    //Or update date of last email in iron_cache
     echo("setting iron_cache\n");
     $cache = new IronCache(array(
         'token' => $payload->token,
         'project_id' => $payload->project_id
     ));
     $res = $cache->putItem('mail',$email, date("D M d, Y G:i"));
     print_r($res);
   }
}

$args = getArgs();
print_r($args);
$payload = $args['payload'];
$mail = init_mail($payload);
echo("Sending email\n");

//what we received array of emails or single email
if(is_array($payload->to))
{
foreach($payload->to as $email)
    {
    //array
        send_mail($email, $payload->from, $payload->subject, $payload->body,$mail);
        update_message_status($payload, $email);
    }
} else {
    //single email
    send_mail($payload->to, $payload->from, $payload->subject, $payload->body,$mail);
    update_message_status($payload, $payload->to);
}

?>
