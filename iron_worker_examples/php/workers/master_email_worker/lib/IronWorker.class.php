<?php
/**
 * PHP client for IronWorker
 * IronWorker is a massively scalable background processing system.
 *
 * @link https://github.com/iron-io/iron_worker_php
 * @link http://www.iron.io/
 * @link http://dev.iron.io/
 * @version 1.3.1
 * @package IronWorkerPHP
 * @copyright Feel free to copy, steal, take credit for, or whatever you feel like doing with this code. ;)
 */

/**
 * IronWorker internal exceptions representation
 */
class IronWorker_Exception extends Exception{

}

/**
 * Class that wraps IronWorker API calls.
 */
class IronWorker extends IronCore{

    protected $client_version = '1.2.1';
    protected $client_name    = 'iron_worker_php';    
    protected $product_name   = 'iron_worker';
    protected $default_values = array(
        'protocol'    => 'https',
        'host'        => 'worker-aws-us-east-1.iron.io',
        'port'        => '443',
        'api_version' => '2',
    );

    /**
     * @param string|array|null $config_file_or_options
     *        Array of options or name of config file.
     * Fields in options array or in config:
     *
     * Required:
     * - token
     * - project_id
     * Optional:
     * - protocol
     * - host
     * - port
     * - api_version
     *
     * Configuration data will be searched in this locations:
     * 1.  passed to class constructor
     * 2a. config file iron.ini in current directory
     * 2b. config file iron.json in current directory
     * 3a. environment variables IRON_WORKER_TOKEN and others
     * 3b. environment variables IRON_TOKEN and others
     * 4a. config file ~/.iron.ini in user home dir
     * 4b. config file ~/.iron.json in user home dir
     *
     */
    function __construct($config_file_or_options = null){
        $this->getConfigData($config_file_or_options);
        $this->url = "{$this->protocol}://{$this->host}:{$this->port}/{$this->api_version}/";
    }

    /**
     * Zips and uploads your code
     *
     * Shortcut for zipDirectory() + postCode()
     *
     * @param string $directory Directory with worker files
     * @param string $run_filename This file will be launched as worker
     * @param string $code_name Referenceable (unique) name for your worker
     * @return bool Result of operation
     * @throws Exception
     */
    public function upload($directory, $run_filename, $code_name){
        $temp_file = tempnam(sys_get_temp_dir(), 'iron_worker_php');
        if (!self::zipDirectory($directory, $temp_file, true)){
            unlink($temp_file);
            return false;
        }
        try{
            $response = $this->postCode($run_filename, $temp_file, $code_name);
            $is_ok = ($response->status_code == 200);
        }catch(Exception $e){
            unlink($temp_file);
            throw $e;
        }
        return $is_ok;
    }

    /**
     * Creates a zip archieve from array of file names
     *
     * Example:
     * <code>
     * IronWorker::createZip(dirname(__FILE__), array('HelloWorld.php'), 'worker.zip', true);
     * </code>
     *
     * @static
     * @param string $base_dir Full path to directory which contain files
     * @param array $files File names, path (both passesed and stored) is relative to $base_dir.
     *        Examples: 'worker.php','lib/file.php'
     * @param string $destination Zip file name.
     * @param bool $overwrite Overwite existing file or not.
     * @return bool
     */
    public static function createZip($base_dir, $files = array(), $destination, $overwrite = false) {
        //if the zip file already exists and overwrite is false, return false
        if(file_exists($destination) && !$overwrite) { return false; }
        if (!empty($base_dir)) $base_dir = rtrim($base_dir, DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR;
        //vars
        $valid_files = array();
        //if files were passed in...
        if(is_array($files)) {
            //cycle through each file
            foreach($files as $file) {
                //make sure the file exists
                if(file_exists($base_dir.$file)) {
                    $valid_files[] = $file;
                }
            }
        }
        if(count($valid_files)) {
            $zip = new ZipArchive();
            if($zip->open($destination,$overwrite ? ZIPARCHIVE::OVERWRITE : ZIPARCHIVE::CREATE) !== true) {
                return false;
            }
            foreach($valid_files as $file) {
                $zip->addFile($base_dir.$file, $file);
            }
            $zip->close();
            return file_exists($destination);
        }else{
            return false;
        }
    }

    /**
     * Creates a zip archieve with all files and folders inside specific directory.
     *
     * Example:
     * <code>
     * IronWorker::zipDirectory(dirname(__FILE__)."/worker/", 'worker.zip', true);
     * </code>
     *
     * @static
     * @param string $directory
     * @param string $destination
     * @param bool $overwrite
     * @return bool
     */
    public static function zipDirectory($directory, $destination, $overwrite = false){
        if (!file_exists($directory) || !is_dir($directory)) return false;
        $directory = rtrim($directory, DIRECTORY_SEPARATOR);

        $files = self::fileNamesRecursive($directory);

        if (empty($files)) return false;

        return self::createZip($directory, $files, $destination, $overwrite);
    }

    public function setProjectId($project_id) {
        if (!empty($project_id)){
          $this->project_id = $project_id;
        }
        if (empty($this->project_id)){
            throw new InvalidArgumentException("Please set project_id");
        }
    }

    public function getProjects(){
        $this->setJsonHeaders();
        $projects = self::json_decode($this->apiCall(self::GET, 'projects'));
        return $projects->projects;
    }

    public function getTasks($page = 0, $per_page = 30){
        $url = "projects/{$this->project_id}/tasks";
        $this->setJsonHeaders();
        $params = array(
            'page'     => $page,
            'per_page' => $per_page
        );
        $task = self::json_decode($this->apiCall(self::GET, $url, $params));
        return $task->tasks;
    }

    public function getProjectDetails(){
        $this->setJsonHeaders();
        $url =  "projects/{$this->project_id}";
        return json_decode($this->apiCall(self::GET, $url));
    }

    public function getCodes($page = 0, $per_page = 30){
        $url = "projects/{$this->project_id}/codes";
        $this->setJsonHeaders();
        $params = array(
            'page'     => $page,
            'per_page' => $per_page
        );
        $codes = self::json_decode($this->apiCall(self::GET, $url, $params));
        return $codes->codes;
    }

    public function getCodeDetails($code_id){
        if (empty($code_id)){
            throw new InvalidArgumentException("Please set code_id");
        }
        $this->setJsonHeaders();
        $url = "projects/{$this->project_id}/codes/$code_id";
        return self::json_decode($this->apiCall(self::GET, $url));
    }

    /**
     * Uploads your code package
     *
     * @param string $filename This file will be launched as worker
     * @param string $zipFilename zip file containing code to execute
     * @param string $name referenceable (unique) name for your worker
     * @return mixed
     */
    public function postCode($filename, $zipFilename, $name){

        // Add IronWorker functions to the uploaded worker
        $this->addRunnerToArchive($zipFilename, $filename);

        $this->setPostHeaders();
        $ts = time();
        $runtime_type = $this->runtimeFileType($filename);
        $sendingData = array(
            "code_name"  => $name,
            "name"       => $name,
            "standalone" => True,
            "runtime"    => $runtime_type,
            "file_name"  => "runner.php",
            "version"    => $this->version,
            "timestamp"  => $ts,
            "oauth"      => $this->token,
            "class_name" => $name,
            "options"    => array(),
            "access_key" => $name
        );
        $url = "projects/{$this->project_id}/codes";
        $post = array(
            "data" => json_encode($sendingData),
            "file"=>"@".$zipFilename,
        );
        $response = $this->apiCall(self::POST, $url, array(), $post);
        return self::json_decode($response);
    }

    public function deleteCode($code_id){
        $url = "projects/{$this->project_id}/codes/$code_id";
        return $this->apiCall(self::DELETE, $url);
    }

    public function deleteSchedule($schedule_id){
        $url = "projects/{$this->project_id}/schedules/$schedule_id/cancel";

        $request = array(
            'schedule_id' => $schedule_id
        );

        return self::json_decode($this->apiCall(self::POST, $url, $request));
    }

    /**
     * Get information about all schedules for project
     *
     * @param int $page
     * @param int $per_page
     * @return mixed
     */
    public function getSchedules($page = 0, $per_page = 30){
        $url = "projects/{$this->project_id}/schedules";
        $this->setJsonHeaders();
        $params = array(
            'page'     => $page,
            'per_page' => $per_page
        );
        $schedules = self::json_decode($this->apiCall(self::GET, $url, $params));
        return $schedules->schedules;
    }

    /**
     * Get information about schedule
     *
     * @param string $schedule_id Schedule ID
     * @return mixed
     * @throws InvalidArgumentException
     */
    public function getSchedule($schedule_id){
        if (empty($schedule_id)){
            throw new InvalidArgumentException("Please set schedule_id");
        }
        $this->setJsonHeaders();
        $url = "projects/{$this->project_id}/schedules/$schedule_id";

        return self::json_decode($this->apiCall(self::GET, $url));
    }

    /**
     * Schedules task
     *
     * @param string $name Package name
     * @param array $payload Payload for task
     * @param int $delay Delay in seconds
     * @return string Created Schedule id
     */
    public function postScheduleSimple($name, $payload = array(), $delay = 1){
        return $this->postSchedule($name, array('delay' => $delay), $payload);
    }

    /**
     * Schedules task
     *
     * @param string        $name       Package name
     * @param array         $payload    Payload for task
     * @param int|DateTime  $start_at   Time of first run in unix timestamp format or as DateTime instance. Example: time()+2*60
     * @param int           $run_every  Time in seconds between runs. If omitted, task will only run once.
     * @param int|DateTime  $end_at     Time tasks will stop being enqueued in unix timestamp or as DateTime instance format.
     * @param int           $run_times  Number of times to run task.
     * @param int           $priority   Priority queue to run the job in (0, 1, 2). p0 is default.
     * @return string Created Schedule id
     */
    public function postScheduleAdvanced($name, $payload = array(), $start_at, $run_every = null, $end_at = null, $run_times = null, $priority = null){
        $options = array();
        $options['start_at'] = self::dateRfc3339($start_at);
        if (!empty($run_every)) $options['run_every'] = $run_every;
        if (!empty($end_at))    $options['end_at']    = self::dateRfc3339($end_at);
        if (!empty($run_times)) $options['run_times'] = $run_times;
        if (!empty($priority))  $options['priority']  = $priority;
        return $this->postSchedule($name, $options, $payload);
    }

    /**
     * Queues already uploaded worker
     *
     * @param string $name Package name
     * @param array $payload Payload for task
     * @param array $options Optional parameters:
     *  - "priority" priority queue to run the job in (0, 1, 2). 0 is default.
     *  - "timeout" maximum runtime of your task in seconds. Maximum time is 3600 seconds (60 minutes). Default is 3600 seconds (60 minutes).
     *  - "delay" delay before actually queueing the task in seconds. Default is 0 seconds.
     * @return string Created Task ID
     */
    public function postTask($name, $payload = array(), $options = array()){
        $url = "projects/{$this->project_id}/tasks";

        $request = array(
            'tasks' => array(
                array(
                    "name"      => $name,
                    "code_name" => $name,
                    'payload' => json_encode($payload),
                )
            )
        );

        foreach ($options as $k => $v){
            $request['tasks'][0][$k] = $v;
        }

        $this->setCommonHeaders();
        $res = $this->apiCall(self::POST, $url, $request);
        $tasks = self::json_decode($res);
        return $tasks->tasks[0]->id;
    }

    public function getLog($task_id){
        if (empty($task_id)){
            throw new InvalidArgumentException("Please set task_id");
        }
        $this->setJsonHeaders();
        $url = "projects/{$this->project_id}/tasks/$task_id/log";
        $this->headers['Accept'] = "text/plain";
        unset($this->headers['Content-Type']);
        return $this->apiCall(self::GET, $url);
    }

    public function getTaskDetails($task_id){
        if (empty($task_id)){
            throw new InvalidArgumentException("Please set task_id");
        }
        $this->setJsonHeaders();
        $url = "projects/{$this->project_id}/tasks/$task_id";
        return self::json_decode($this->apiCall(self::GET, $url));
    }

    /**
     * Cancels task.
     *
     * @param string $task_id Task ID
     * @return mixed
     * @throws InvalidArgumentException
     */
    public function cancelTask($task_id){
        if (empty($task_id)){
            throw new InvalidArgumentException("Please set task_id");
        }
        $url = "projects/{$this->project_id}/tasks/$task_id/cancel";
        $request = array();

        $this->setCommonHeaders();
        $res = $this->apiCall(self::POST, $url, $request);
        return self::json_decode($res);
    }

    /**
     * Cancels task.
     *
     * @param string $task_id Task ID
     * @return mixed
     * @throws InvalidArgumentException
     */
    public function deleteTask($task_id){
        return $this->cancelTask($task_id);
    }

    public function setTaskProgress($task_id, $percent, $msg = ''){
        if (empty($task_id)){
            throw new InvalidArgumentException("Please set task_id");
        }
        $url = "projects/{$this->project_id}/tasks/$task_id/progress";
        $request = array(
            'percent' => $percent,
            'msg'     => $msg
        );

        $this->setCommonHeaders();
        return self::json_decode($this->apiCall(self::POST, $url, $request));
    }
    /**
     * Wait while the task specified by task_id executes
     *
     * @param string $task_id Task ID
     * @param int $sleep Delay between API invocations in seconds
     * @param int $max_wait_time Maximum waiting time in seconds, 0 for infinity
     * @return mixed $details Task details or false
     */
    public function waitFor($task_id, $sleep = 5, $max_wait_time = 0){
        while(1){
            $details = $this->getTaskDetails($task_id);

            if ($details->status != 'queued' && $details->status != 'running'){
                return $details;
            }
            if ($max_wait_time > 0){
                $max_wait_time -= $sleep;
                if ($max_wait_time <= 0) return false;
            }

            sleep($sleep);
        }
        return false;
    }

    /* PRIVATE FUNCTIONS */

    /**
     *
     * @param string $name
     * @param array $options options contain:
     *   start_at OR delay — required - start_at is time of first run. Delay is number of seconds to wait before starting.
     *   run_every         — optional - Time in seconds between runs. If omitted, task will only run once.
     *   end_at            — optional - Time tasks will stop being enqueued. (Should be a Time or DateTime object.)
     *   run_times         — optional - Number of times to run task. For example, if run_times: is 5, the task will run 5 times.
     *   priority          — optional - Priority queue to run the job in (0, 1, 2). p0 is default. Run at higher priorities to reduce time jobs may spend in the queue once they come off schedule. Same as priority when queuing up a task.
     * @param array $payload
     * @return mixed
     */
    private function postSchedule($name, $options, $payload = array()){
        $url = "projects/{$this->project_id}/schedules";
        $shedule = array(
           'name' => $name,
           'code_name' => $name,
           'payload' => json_encode($payload),
        );
        $request = array(
           'schedules' => array(
               array_merge($shedule, $options)
           )
        );

        $this->setCommonHeaders();
        $res = $this->apiCall(self::POST, $url, $request);
        $shedules = self::json_decode($res);
        return $shedules->schedules[0]->id;
    }

    private function runtimeFileType($name) {
        if(empty($name)){
            return false;
        }
        $explodedName= explode(".", $name);
        switch ($explodedName[(count($explodedName)-1)]) {
            case "php":
                return "php";
            case "rb":
                return "ruby";
            case "py":
                return "python";
            case "javascript":
                return "javascript";
            default:
                return "no_type_found";
        }
    }

    private function getFileContent($filename){
        return file_get_contents($filename);
    }

    private function setJsonHeaders(){
        $this->setCommonHeaders();
    }

    private function setPostHeaders(){
        $this->setCommonHeaders();
        $this->headers['Content-Type'] ='multipart/form-data';
    }

    private static function fileNamesRecursive($dir, $base_dir = ''){
        $dir .= DIRECTORY_SEPARATOR;
        $files = scandir($dir);
        $names = array();

        foreach($files as $name){
             if ($name == '.' || $name == '..' || $name == '.svn') continue;
             if (is_dir($dir.$name)){
                 $inner_names = self::fileNamesRecursive($dir.$name, $base_dir.$name.'/');
                 foreach ($inner_names as $iname){
                     $names[] = $iname;
                 }
             }else{
                 $names[] = $base_dir.$name;
             }
        }
        return $names;
    }


    /**
     * Contain php code that adds to worker before upload
     *
     * @param string $worker_file_name
     * @return string
     */
    private function workerHeader($worker_file_name){
        $header = <<<EOL
        <?php
        /*IRON_WORKER_HEADER*/
        function getArgs(){
            global \$argv;
            \$args = array('task_id' => null, 'dir' => null, 'payload' => array());
            foreach(\$argv as \$k => \$v){
                if (empty(\$argv[\$k+1])) continue;
                if (\$v == '-id') \$args['task_id'] = \$argv[\$k+1];
                if (\$v == '-d')  \$args['dir']     = \$argv[\$k+1];
                if (\$v == '-payload' && file_exists(\$argv[\$k+1])){
                    \$args['payload'] = json_decode(file_get_contents(\$argv[\$k+1]));
                }
            }
            return \$args;
        }

        function getPayload(){
            \$args = getArgs();
            return \$args['payload'];
        }

        function setProgress(\$percent, \$msg = ''){
            \$args = getArgs();
            \$task_id = \$args['task_id'];
            \$base_url   = '[URL]';
            \$project_id = '[PROJECT_ID]';
            \$headers    =  [HEADERS];

            \$url = "{\$base_url}projects/\$project_id/tasks/\$task_id/progress";
            \$params = array(
                'percent' => \$percent,
                'msg'     => \$msg
            );

            \$s = curl_init();
            curl_setopt(\$s, CURLOPT_URL,  \$url);
            curl_setopt(\$s, CURLOPT_POST, true);
            curl_setopt(\$s, CURLOPT_POSTFIELDS, json_encode(\$params));
            curl_setopt(\$s, CURLOPT_RETURNTRANSFER, true);
            curl_setopt(\$s, CURLOPT_HTTPHEADER, \$headers);
            \$out = curl_exec(\$s);
            curl_close(\$s);
            return json_decode(\$out);
        }
        require dirname(__FILE__)."/[SCRIPT]";
EOL;
        $header = str_replace(
            array('[PROJECT_ID]','[URL]','[HEADERS]','[SCRIPT]'),
            array($this->project_id, $this->url, var_export($this->compiledHeaders(), true), $worker_file_name),
            $header
        );
        return trim($header," \n\r");
    }

    private function addRunnerToArchive($archive, $worker_file_name){
        $zip = new ZipArchive;
        if (!$zip->open($archive, ZIPARCHIVE::CREATE) === true) {
            $zip->close();
            throw new IronWorker_Exception("Archive $archive was not found!");
        }

        if ($zip->statName($worker_file_name) === false){
            $zip->close();
            throw new IronWorker_Exception("File $worker_file_name in archive $archive was not found!");
        }

        if (!$zip->addFromString('runner.php', $this->workerHeader($worker_file_name))){
            throw new IronWorker_Exception("Adding Runner to the worker failed");
        }

        $zip->close();
        return true;
    }

}
