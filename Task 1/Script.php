<?php

class Script {

    /**
     * Env names for Redis connection
     */
    const REDIS_HOST = 'REDIS_HOST';
    const REDIS_PORT = 'REDIS_PORT';
    
    /**
     * Key code default name
     */
    const DEFAULT_CODE = 'default_code';

    /**
     * Key code value
     */
    const CODE_VALUE = 'just_key';

    /**
     * Key code custom name
     */
    protected string $_blockCode = '';

    /**
     * Redis client
     */
    protected Redis $_redisClient;

    /**
     * 
     */
    public function __construct()
    {
        $host = getenv(self::REDIS_HOST) ?? '';
        $port = getenv(self::REDIS_PORT) ?? '';

        if (empty($host) || empty($port)) {
            throw new Exception('Redis Host and/or Port were not defined');
        }

        $redis = new Redis();
        $redis->connect($host, $port);
        $this->setRedis($redis);
    }

    /**
     * 
     */
    public function __destruct()
    {
        $this->closeConnection();
    }

    /**
     * Set unique key-code
     * @param string $code
     */
    public function setCode(string $code):void
    {
        if (empty($code)) {
            throw new Exception('Code is empty');
        }
        $this->_blockCode = $code;
    }

    /**
     * Get key-code
     * @return string
     */
    public function getCode():string
    {
        return !empty($this->_blockCode) ? $this->_blockCode : self::DEFAULT_CODE;
    }

    /**
     * Set Redis client
     * @param Redis $client
     */
    public function setRedis(Redis $client):void
    {
        $this->_redisclient = $client;
    }

    /**
     * Get Redis client
     * @return Redis
     */
    public function getRedis():Redis
    {
        if (empty($this->_redisclient)) {
            throw new Exception('Redis client was not set');
        }
        return $this->_redisclient;
    }

    /**
     * Run script
     */
    public function run():void
    {
        if ($this->_inProgress()) {
            throw new Exception('Script is in progress');
            return;
        }

        $this->_block();
        register_shutdown_function(array($this, '_unblock'));

        $this->_launchMainBody();
        $this->_unblock();
    }

    /**
     * Close redis connection
     */
    public function closeConnection():void
    {
        $this->getRedis()->close();
    }

    /**
     * Main script body
     */
    protected function _launchMainBody():void
    {
        sleep(60);
    }

    /**
     * Checks if script is still running
     * @return bool
     */
    protected function _inProgress():bool
    {
        return (bool) $this->getRedis()->exists($this->getCode());
    }

    /**
     * Blocks script from additional launches
     */
    protected function _block():void
    {
        $this->getRedis()->set($this->getCode(), self::CODE_VALUE);
    }

    /**
     * Unblocks script
     */
    protected function _unblock():void
    {
        $this->getRedis()->del($this->getCode());
    }
}

?>