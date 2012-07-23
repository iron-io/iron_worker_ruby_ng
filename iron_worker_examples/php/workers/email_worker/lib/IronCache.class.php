<?php
/**
 * PHP client for IronCache
 *
 * @link https://github.com/iron-io/iron_cache_php
 * @link http://www.iron.io/products/cache
 * @link http://dev.iron.io/
 * @version 0.0.1
 * @package IronCache
 * @copyright Feel free to copy, steal, take credit for, or whatever you feel like doing with this code. ;)
 */


class IronCache_Item {
    private $value;
    private $expires_in;
    private $replace;
    private $add;

    const max_expires_in = 2592000;

    /**
     * Create a new item.
     *
     * @param array|string $item
     *        An array of item properties or a string of the item value.
     * Fields in item array:
     * Required:
     * - value: string - The item data, as a string.
     * Optional:
     * - expires_in: integer - How long in seconds to keep the item on the cache before it is deleted. Default is 604,800 seconds (7 days). Maximum is 2,592,000 seconds (30 days).
     * - replace: boolean - Will only work if key already exists.
     * - add:     boolean - Will only work if key does not exist.
     */
    function __construct($item) {
        if(is_string($item) || is_integer($item)) {
            $this->setValue($item);
        } elseif(is_array($item)) {
            $this->setValue($item['value']);
            if(array_key_exists("replace", $item)) {
                $this->setReplace($item['replace']);
            }
            if(array_key_exists("add", $item)) {
                $this->setAdd($item['add']);
            }
            if(array_key_exists("expires_in", $item)) {
                $this->setExpiresIn($item['expires_in']);
            }
        }
    }

    public function setValue($value) {
        if(empty($value)) {
            throw new InvalidArgumentException("Please specify a value");
        } else {
            $this->value = $value;
        }
    }

    public function getValue() {
        return $this->value;
    }

    public function setReplace($replace) {
        $this->replace = $replace;
    }

    public function getReplace() {
        return $this->replace;
    }

    public function setAdd($add) {
        $this->add = $add;
    }

    public function getAdd() {
        return $this->add;
    }

    public function setExpiresIn($expires_in) {
        if($expires_in > self::max_expires_in) {
            throw new InvalidArgumentException("Expires In can't be greater than ".self::max_expires_in.".");
        } else {
            $this->expires_in = $expires_in;
        }
    }

    public function getExpiresIn(){
        return $this->expires_in;
    }

    public function asArray() {
        $array = array();
        $array['value'] = $this->getValue();
        if($this->getExpiresIn() != null) {
            $array['expires_in'] = $this->getExpiresIn();
        }
        if($this->getReplace() != null) {
            $array['replace'] = $this->getReplace();
        }
        if($this->getAdd() != null) {
            $array['add'] = $this->getAdd();
        }
        return $array;
    }
}

class IronCache extends IronCore{
    protected $client_version = '0.0.1';
    protected $client_name    = 'iron_cache_php';
    protected $product_name   = 'iron_cache';
    protected $default_values = array(
        'protocol'    => 'https',
        'host'        => 'cache-aws-us-east-1.iron.io',
        'port'        => '443',
        'api_version' => '1',
    );

    private $cache_name;

    /**
    * @param string|array $config_file_or_options
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
    * @param string|null $cache_name set default cache name
    */
    function __construct($config_file_or_options = null, $cache_name = null){
        $this->getConfigData($config_file_or_options);
        $this->url = "{$this->protocol}://{$this->host}:{$this->port}/{$this->api_version}/";
        $this->setCacheName($cache_name);
    }

    /**
    * Switch active project
    *
    * @param string $project_id Project ID
    * @throws InvalidArgumentException
    */
    public function setProjectId($project_id) {
        if (!empty($project_id)){
            $this->project_id = $project_id;
        }
        if (empty($this->project_id)){
            throw new InvalidArgumentException("Please set project_id");
        }
    }

    /**
    * Set default cache name
    *
    * @param string $cache_name name of cache
    * @throws InvalidArgumentException
    */
    public function setCacheName($cache_name) {
        if (!empty($cache_name)){
            $this->cache_name = $cache_name;
        }

    }

    public function getCaches($page = 0){
        $url = "projects/{$this->project_id}/caches";
        $params = array();
        if($page > 0) {
            $params['page'] = $page;
        }
        $this->setJsonHeaders();
        return self::json_decode($this->apiCall(self::GET, $url, $params));
    }

    /**
    * Get information about cache.
    * Also returns cache size.
    *
    * @param string $cache
    * @return mixed
    */
    public function getCache($cache) {
        $cache = self::encodeCache($cache);
        $url = "projects/{$this->project_id}/caches/$cache";
        $this->setJsonHeaders();
        return self::json_decode($this->apiCall(self::GET, $url));
    }

    /**
     * Push a item on the cache at 'key'
     *
     * Examples:
     * <code>
     * $cache->postItem("test_cache", 'default', "Hello world");
     * </code>
     * <code>
     * $cache->putItem("test_cache", 'default', array(
     *   "value" => "Test Item",
     *   'expires_in' => 2*24*3600, # 2 days
     *   "replace" => true
     * ));
     * </code>
     *
     * @param string $cache Name of the cache.
     * @param string $key Item key.
     * @param array|string $item
     *
     * @return mixed
     */
    public function putItem($cache, $key, $item) {
        $cache = self::encodeCache($cache);
        $key   = self::encodeKey($key);
        $itm = new IronCache_Item($item);
        $req = $itm->asArray();
        $url = "projects/{$this->project_id}/caches/$cache/items/$key";

        $this->setJsonHeaders();
        $res = $this->apiCall(self::PUT, $url, $req);
        return self::json_decode($res);
    }

    /**
     * Get item from cache by key
     *
     * @param string $cache Cache name
     * @param string $key Cache key
     * @return mixed|null single item or null
     * @throws Http_Exception
     */
    public function getItem($cache, $key) {
        $cache = self::encodeCache($cache);
        $key   = self::encodeKey($key);
        $url   = "projects/{$this->project_id}/caches/$cache/items/$key";

        $this->setJsonHeaders();
        try {
            $res = $this->apiCall(self::GET, $url);
        }catch (Http_Exception $e){
            if ($e->getCode() == Http_Exception::NOT_FOUND){
                return null;
            }else{
                throw $e;
            }
        }
        return self::json_decode($res);
    }

    public function deleteItem($cache, $key) {
        $cache = self::encodeCache($cache);
        $key   = self::encodeKey($key);
        $url   = "projects/{$this->project_id}/caches/$cache/items/$key";

        $this->setJsonHeaders();
        return self::json_decode($this->apiCall(self::DELETE, $url));
    }

    /**
     * Atomically increments the value for key by amount.
     * Can be used for both increment and decrement by passing a negative value.
     * The value must exist and must be an integer.
     * The number is treated as an unsigned 64-bit integer.
     * The usual overflow rules apply when adding, but subtracting from 0 always yields 0.
     *
     * @param string $cache
     * @param string $key
     * @param int $amount Change by this value
     * @return mixed|void
     */
    public function incrementItem($cache, $key, $amount = 1){
        $cache = self::encodeCache($cache);
        $key   = self::encodeKey($key);
        $url = "projects/{$this->project_id}/caches/$cache/items/$key/increment";
        $params = array(
            'amount' => $amount
        );
        $this->setJsonHeaders();
        return self::json_decode($this->apiCall(self::POST, $url, $params));
    }


    /**
     * Shortcut for getItem($cache, $key)
     * Please set $cache name before use by setCacheName() method
     *
     * @param string $key
     * @return mixed|null
     * @throws InvalidArgumentException
     */
    public function get($key){
        return $this->getItem($this->cache_name, $key);
    }

    /**
     * Shortcut for postItem($cache, $key, $item)
     * Please set $cache name before use by setCacheName() method
     *
     * @param string $key
     * @param array|string $item
     * @return mixed
     * @throws InvalidArgumentException
     */
    public function put($key, $item){
        return $this->putItem($this->cache_name, $key, $item);
    }

    /**
     * Shortcut for deleteItem($cache, $key)
     * Please set $cache name before use by setCacheName() method
     *
     * @param string $key
     * @return mixed|void
     * @throws InvalidArgumentException
     */
    public function delete($key){
        return $this->deleteItem($this->cache_name, $key);
    }

    /**
     * Shortcut for incrementItem($cache, $key, $amount)
     * Please set $cache name before use by setCacheName() method
     *
     * @param string $key
     * @param int $amount
     * @return mixed|void
     * @throws InvalidArgumentException
     */
    public function increment($key, $amount = 1){
        return $this->incrementItem($this->cache_name, $key, $amount);
    }

    /* PRIVATE FUNCTIONS */

    private static function encodeCache($cache){
        if (empty($cache)){
            throw new InvalidArgumentException('Please set $cache variable');
        }
        return rawurlencode($cache);
    }

    private static function encodeKey($key){
        if (empty($key)){
            throw new InvalidArgumentException('Please set $key variable');
        }
        return rawurlencode($key);
    }


    private function setJsonHeaders(){
        $this->setCommonHeaders();
    }

    private function setPostHeaders(){
        $this->setCommonHeaders();
        $this->headers['Content-Type'] ='multipart/form-data';
    }

}