<?

/**
 * List peer used for filtered list functionality
 */
class redis_set_peer
{
	protected $name_space;

	public function  __construct()
	{
		$this->name_space = get_class($this);
	}

	/**
	 * @return php_redis
	 */
	public function get_connection()
	{
		return redis_pool::get('master');
	}

	public function clear($key)
	{
		$this->get_connection()->delete($this->name_space . $key);
	}

	public function add( $key, $value )
	{
		return $this->get_connection()->add_member($this->name_space . $key, $value);
	}

	public function remove( $key, $value )
	{
		return $this->get_connection()->remove_member($this->name_space . $key, $value);
	}

	public function is_member( $key, $value )
	{
		return $this->get_connection()->is_member($this->name_space . $key, $value);
	}

	public function get_all( $key )
	{
		return $this->get_connection()->get_members($this->name_space . $key);
	}

	public function get_count( $key )
	{
		return $this->get_connection()->get_members_count($this->name_space . $key);
	}
}