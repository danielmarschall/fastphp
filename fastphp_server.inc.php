<?php

if (isset($argv[1])) {
	$ary = explode('&', $argv[1]);
	foreach ($ary as $chunk) {
		if (trim($chunk) == '') continue;
		$param = explode("=", $chunk);
		// TODO: also accept parameters without value. as well as arrays...
		$_GET[urldecode($param[0])] = urldecode($param[1]);
		unset($param);
	}
	unset($chunk);
	unset($ary);
}

if (isset($argv[2])) {
	$ary = explode('&', $argv[2]);
	foreach ($ary as $chunk) {
		if (trim($chunk) == '') continue;
		$param = explode("=", $chunk);
		$_POST[urldecode($param[0])] = urldecode($param[1]);
		unset($param);
	}
	unset($chunk);
	unset($ary);
}

foreach ($_GET as $name => $val) $_REQUEST[$name] = $val;
foreach ($_POST as $name => $val) $_REQUEST[$name] = $val;
unset($name);
unset($val);

// TODO: headers... cookies... decoding of POST (see header)...
$_HEADER = array();
if (isset($argv[3])) {
	$ary = $argv[3];
	$ary = str_replace('|CR|', "\r", $ary);
	$ary = str_replace('|LF|', "\n", $ary);
	$ary = explode("\r\n", $ary);
	foreach ($ary as $chunk) {
		if ($chunk == '') continue;
		$param = explode(":", $chunk);
		$_HEADER[trim($param[0])] = trim($param[1]); // FastPHP specific
		// TODO: also generate some usual 
		
		// TODO: get more of these: http://php.net/manual/de/reserved.variables.server.php
		// TODO: case sensitive?
		if (trim($param[0]) == 'User-Agent') $_SERVER['HTTP_USER_AGENT'] = trim($param[1]);
		if (trim($param[0]) == 'Referer') $_SERVER['HTTP_REFERER'] = trim($param[1]);
		
		unset($param);	
	}
	unset($chunk);
	unset($ary);
}



# ---

// https://gist.github.com/pokeb/10590
/*
function parse_cookies($header) {
	
	$cookies = array();
	
	$cookie = new cookie();
	
	$parts = explode("=",$header);
	for ($i=0; $i< count($parts); $i++) {
		$part = $parts[$i];
		if ($i==0) {
			$key = $part;
			continue;
		} elseif ($i== count($parts)-1) {
			$cookie->set_value($key,$part);
			$cookies[] = $cookie;
			continue;
		}
		$comps = explode(" ",$part);
		$new_key = $comps[count($comps)-1];
		$value = substr($part,0,strlen($part)-strlen($new_key)-1);
		$terminator = substr($value,-1);
		$value = substr($value,0,strlen($value)-1);
		$cookie->set_value($key,$value);
		if ($terminator == ",") {
			$cookies[] = $cookie;
			$cookie = new cookie();
		}
		
		$key = $new_key;
	}
	return $cookies;
}

class cookie {
	public $name = "";
	public $value = "";
	public $expires = "";
	public $domain = "";
	public $path = "";
	public $secure = false;
	
	public function set_value($key,$value) {
		switch (strtolower($key)) {
			case "expires":
				$this->expires = $value;
				return;
			case "domain":
				$this->domain = $value;
				return;
			case "path":
				$this->path = $value;
				return;
			case "secure":
				$this->secure = ($value == true);
				return;
		}
		if ($this->name == "" && $this->value == "") {
			$this->name = $key;
			$this->value = $value;
		}
	}
}
*/
