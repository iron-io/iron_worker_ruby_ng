<?

class redis_pool
{
	private static $connections = array();
	private static $servers = array();

	public static function add_servers( $list )
	{
		foreach ( $list as $alias => $data )
		{
			self::$servers[$alias] = $data;
		}
	}

	public static function get( $alias )
	{
		if ( !array_key_exists($alias, self::$connections) )
		{
			self::$connections[$alias] = new php_redis(self::$servers[$alias][0], self::$servers[$alias][1]);
		}

		return self::$connections[$alias];
	}
}