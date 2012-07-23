<?php
/**
 * Core functionality for Iron.io products
 *
 * @link https://github.com/iron-io/iron_core_php
 * @link http://www.iron.io/
 * @link http://dev.iron.io/
 * @version 0.0.2
 * @package IronCore
 * @copyright BSD 2-Clause License. See LICENSE file.
 */

class IronCore{
    protected $core_version = '0.0.1';

    // should be overridden by child class
    protected $client_version = null;
    protected $client_name    = null;
    protected $product_name   = null;
    protected $default_values = null;

    const HTTP_OK = 200;
    const HTTP_CREATED = 201;
    const HTTP_ACCEPTED = 202;

    const POST   = 'POST';
    const PUT    = 'PUT';
    const GET    = 'GET';
    const DELETE = 'DELETE';

    const header_accept = "application/json";
    const header_accept_encoding = "gzip, deflate";

    protected $url;
    protected $token;
    protected $api_version;
    protected $version;
    protected $project_id;
    protected $headers;
    protected $protocol;
    protected $host;
    protected $port;

    public  $max_retries = 5;
    public  $debug_enabled = false;
    public  $ssl_verifypeer = true;


    protected static function dateRfc3339($timestamp = 0) {
        if ($timestamp instanceof DateTime) {
            $timestamp = $timestamp->getTimestamp();
        }
        if (!$timestamp) {
            $timestamp = time();
        }
        return gmdate('c', $timestamp);
    }

    protected static function json_decode($response){
        $data = json_decode($response);
        if (function_exists('json_last_error')){
            $json_error = json_last_error();
            if($json_error != JSON_ERROR_NONE) {
                throw new JSON_Exception($json_error);
            }
        }elseif($data === null){
            throw new JSON_Exception("Common JSON error");
        }
        return $data;
    }


    protected static function homeDir(){
        if ($home_dir = getenv('HOME')){
            // *NIX
            return $home_dir.DIRECTORY_SEPARATOR;
        }else{
            // Windows
            return getenv('HOMEDRIVE').getenv('HOMEPATH').DIRECTORY_SEPARATOR;
        }
    }

    protected function debug($var_name, $variable){
        if ($this->debug_enabled){
            echo "{$var_name}: ".var_export($variable,true)."\n";
        }
    }

    protected function userAgent(){
        return "{$this->client_name}-{$this->client_version} (iron_core-{$this->core_version})";
    }

    /**
     * Load configuration
     *
     * @param array|string|null $config_file_or_options
     * array of options or name of config file
     * @return array
     * @throws InvalidArgumentException
     */
    protected function getConfigData($config_file_or_options){
        if(is_string($config_file_or_options)){
            if (!file_exists($config_file_or_options)){
                throw new InvalidArgumentException("Config file $config_file_or_options not found");
            }
            $this->loadConfigFile($config_file_or_options);
        }elseif(is_array($config_file_or_options)){
            $this->loadFromHash($config_file_or_options);
        }

        $this->loadConfigFile('iron.ini');
        $this->loadConfigFile('iron.json');

        $this->loadFromEnv(strtoupper($this->product_name));
        $this->loadFromEnv('IRON');

        $this->loadConfigFile(self::homeDir() . '.iron.ini');
        $this->loadConfigFile(self::homeDir() . '.iron.json');

        $this->loadFromHash($this->default_values);

        if (empty($this->token) || empty($this->project_id)){
            throw new InvalidArgumentException("token or project_id not found in any of the available sources");
        }
    }


    protected function loadFromHash($options){
        if (empty($options)) return;
        $this->setVarIfValue('token',       $options);
        $this->setVarIfValue('project_id',  $options);
        $this->setVarIfValue('protocol',    $options);
        $this->setVarIfValue('host',        $options);
        $this->setVarIfValue('port',        $options);
        $this->setVarIfValue('api_version', $options);
    }

    protected function loadFromEnv($prefix){
        $this->setVarIfValue('token',       getenv($prefix. "_TOKEN"));
        $this->setVarIfValue('project_id',  getenv($prefix. "_PROJECT_ID"));
        $this->setVarIfValue('protocol',    getenv($prefix. "_SCHEME"));
        $this->setVarIfValue('host',        getenv($prefix. "_HOST"));
        $this->setVarIfValue('port',        getenv($prefix. "_PORT"));
        $this->setVarIfValue('api_version', getenv($prefix. "_API_VERSION"));
    }

    protected function setVarIfValue($key, $options_or_value){
        if (!empty($this->$key)) return;
        if (is_array($options_or_value)){
            if (!empty($options_or_value[$key])){
                $this->$key = $options_or_value[$key];
            }
        }else{
            if (!empty($options_or_value)){
                $this->$key = $options_or_value;
            }
        }
    }

    protected function loadConfigFile($file){
        if (!file_exists($file)) return;
        $data = @parse_ini_file($file, true);
        if ($data === false){
            $data = json_decode(file_get_contents($file), true);
        }
        if (!is_array($data)){
            throw new InvalidArgumentException("Config file $file not parsed");
        };

        if (!empty($data[$this->product_name])) $this->loadFromHash($data[$this->product_name]);
        if (!empty($data['iron'])) $this->loadFromHash($data['iron']);
        $this->loadFromHash($data);
    }

    protected function apiCall($type, $url, $params = array(), $raw_post_data = null){
        $url = "{$this->url}$url";

        $s = curl_init();
        if (! isset($params['oauth'])) {
          $params['oauth'] = $this->token;
        }
        switch ($type) {
            case self::DELETE:
                $url .= '?' . http_build_query($params);
                curl_setopt($s, CURLOPT_URL, $url);
                curl_setopt($s, CURLOPT_CUSTOMREQUEST, self::DELETE);
                break;
            case self::PUT:
                curl_setopt($s, CURLOPT_URL, $url);
                curl_setopt($s, CURLOPT_CUSTOMREQUEST, self::PUT);
                curl_setopt($s, CURLOPT_POSTFIELDS, json_encode($params));
                break;
            case self::POST:
                curl_setopt($s, CURLOPT_URL,  $url);
                curl_setopt($s, CURLOPT_POST, true);
                if ($raw_post_data){
                    curl_setopt($s, CURLOPT_POSTFIELDS, $raw_post_data);
                }else{
                    curl_setopt($s, CURLOPT_POSTFIELDS, json_encode($params));
                }
                break;
            case self::GET:
                $url .= '?' . http_build_query($params);
                curl_setopt($s, CURLOPT_URL, $url);
                break;
        }
        $this->debug('apiCall full Url', $url);
        curl_setopt($s, CURLOPT_SSL_VERIFYPEER, $this->ssl_verifypeer);
        curl_setopt($s, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($s, CURLOPT_HTTPHEADER, $this->compiledHeaders());
        return $this->callWithRetries($s);
    }

    protected function callWithRetries($s){
        for ($retry = 0; $retry < $this->max_retries; $retry++){
            $_out = curl_exec($s);
            $status = curl_getinfo($s, CURLINFO_HTTP_CODE);
            switch ($status) {
                case self::HTTP_OK:
                case self::HTTP_CREATED:
                case self::HTTP_ACCEPTED:
                    curl_close($s);
                    return $_out;
                case Http_Exception::INTERNAL_ERROR:
                    if (strpos($_out, "EOF") !== false){
                        self::waitRandomInterval($retry);
                    }else{
                        curl_close($s);
                        $this->reportHttpError($status, $_out);
                    }
                    break;
                case Http_Exception::SERVICE_UNAVAILABLE:
                    self::waitRandomInterval($retry);
                    break;
                default:
                    curl_close($s);
                    $this->reportHttpError($status, $_out);
            }
        }
        curl_close($s);
        return $this->reportHttpError(503, "Service unavailable");
    }

    protected function reportHttpError($status, $text){
        throw new Http_Exception("http error: {$status} | {$text}", $status);
    }

    /**
     * Wait for a random time between 0 and (4^currentRetry * 100) milliseconds
     *
     * @static
     * @param int $retry currentRetry number
     */
    protected static function waitRandomInterval($retry){
        $max_delay = pow(4, $retry)*100*1000;
        usleep(rand(0, $max_delay));
    }

    protected function compiledHeaders(){
        # Set default headers if no headers set.
        if ($this->headers == null){
            $this->setCommonHeaders();
        }

        $headers = array();
        foreach ($this->headers as $k => $v){
            $headers[] = "$k: $v";
        }
        return $headers;
    }

    protected function setCommonHeaders(){
        $this->headers = array(
            'Authorization'   => "OAuth {$this->token}",
            'User-Agent'      => $this->userAgent(),
            'Content-Type'    => 'application/json',
            'Accept'          => self::header_accept,
            'Accept-Encoding' => self::header_accept_encoding
        );
    }

}

/**
 * The Http_Exception class represents an HTTP response status that is not 200 OK.
 */
class Http_Exception extends Exception{
    const NOT_MODIFIED = 304;
    const BAD_REQUEST = 400;
    const NOT_FOUND = 404;
    const NOT_ALLOWED = 405;
    const CONFLICT = 409;
    const PRECONDITION_FAILED = 412;
    const INTERNAL_ERROR = 500;
    const SERVICE_UNAVAILABLE = 503;
}

/**
 * The JSON_Exception class represents an failures of decoding json strings.
 */
class JSON_Exception extends Exception {
    public $error = null;
    public $error_code = JSON_ERROR_NONE;

    function __construct($error_code) {
        $this->error_code = $error_code;
        switch($error_code) {
            case JSON_ERROR_DEPTH:
                $this->error = 'Maximum stack depth exceeded.';
                break;
            case JSON_ERROR_CTRL_CHAR:
                $this->error = "Unexpected control characted found.";
                break;
            case JSON_ERROR_SYNTAX:
                $this->error = "Syntax error, malformed JSON";
                break;
            default:
                $this->error = $error_code;
                break;

        }
        parent::__construct();
    }

    function __toString() {
        return $this->error;
    }
}

