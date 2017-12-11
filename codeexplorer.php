<?php

define('ICON_ATTR_PUBLIC',           1);
define('ICON_ATTR_PRIVATE',          2);
define('ICON_ATTR_PROTECTED',        4);
define('ICON_ATTR_ABSTRACT',         8);
define('ICON_ATTR_STATIC',          16);
define('ICON_ATTR_CONST',           32);
define('ICON_ATTR_VAR',             64);
define('ICON_ATTR_FUNCTION',       128);
define('ICON_ATTR_CONSTRUCTOR',    256);
define('ICON_ATTR_DESTRUCTOR',     512);
define('ICON_ATTR_MAGICMETHOD',   1024);
define('ICON_ATTR_CLASS',         2048);
define('ICON_ATTR_TRAIT',         4096);
define('ICON_ATTR_INTERFACE',     8192);

error_reporting(0);

while (true) {
	$lines = array();
	while ($f = fgets(STDIN)){
		if (trim($f) == chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8)) break;
		$lines[] = $f;
	}
	$code = implode("", $lines);

	echo "FAST100!\n";
	
	$x = token_get_all($code);
	
	// file_put_contents('debug.tmp', $code);
	
	if (!$x) {
		// TODO: when this happens, do not update the output in the editor...
		echo _outputLeafNode(2048, 1, 'SYNTAX ERROR');
	}
	
	//print_r($x); // debug
	$wait_function = false;
	$wait_class = false;
	$class = array();
	$icon_add_flags = 0;
	$dep = 0;

	foreach ($x as $n => $data) {
		if ($data == '{') $dep++;
		if ($data == '}') {
			$dep--;
			if ((count($class) > 0) && (array_peek($class)[1] == $dep)) {
				array_pop($class);
				echo _outputDecreaseLevel();
			}
		}

		$token = (!is_array($data)) ? null : $data[0];
		$value = (!is_array($data)) ? null : $data[1];
		$line = (!is_array($data)) ? null : $data[2];

		if ($wait_function && ($token == T_STRING)) {
			$desc = "function ";
			/*
			foreach ($class as $cdata) {
				$desc .= $cdata[0].'->';
			}
			*/
			$desc .= "$value()";
			$icon_add_flags = 0;
			$wait_function = false;

			if ($value == '__construct') { // TODO: auch eine methode mit dem namen der klasse soll eine konstruktor sein
				echo _outputLeafNode(ICON_ATTR_CONSTRUCTOR | $icon_add_flags, $line, $desc);
			} else if ($value == '__destruct') {
				echo _outputLeafNode(ICON_ATTR_DESTRUCTOR  | $icon_add_flags, $line, $desc);
			} else if (substr($value, 0, 2) == '__') {
				echo _outputLeafNode(ICON_ATTR_MAGICMETHOD | $icon_add_flags, $line, $desc);
			} else {
				echo _outputLeafNode(ICON_ATTR_FUNCTION    | $icon_add_flags, $line, $desc);
			}
		}

		if ($wait_class && ($token == T_STRING)) {
			$desc = "Class ";
			/*
			foreach ($class as $cdata) {
				$desc .= $cdata[0].'->';
			}
			*/
			$desc .= "$value\n";
			$class[] = array($value, $dep);
			$wait_class = false;

			echo _outputLeafNode(ICON_ATTR_CLASS | $icon_add_flags, $line, $desc);
                        echo _outputIncreaseLevel();
		}

		if ($token == T_PUBLIC)    $icon_add_flags |= ICON_ATTR_PUBLIC;
		if ($token == T_PRIVATE)   $icon_add_flags |= ICON_ATTR_PRIVATE;
		if ($token == T_PROTECTED) $icon_add_flags |= ICON_ATTR_PROTECTED;
		if ($token == T_STATIC)    $icon_add_flags |= ICON_ATTR_STATIC;
		if (($data == ';') || ($data == '{') || ($data == '}')) $icon_add_flags = 0;

		if ($token == T_FUNCTION) {
			$wait_function = true;
		}
		if ($token == T_CLASS) {
			$wait_class = true;
			$dep = 0;
		}

		if ($token == T_COMMENT) {
			if (stripos($value, 'TODO') !== false) {
				echo _outputLeafNode(0/*TODO*/, $line, $value);
			}
		}
	}
	
	echo _outputExit();

	echo chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8);

	sleep(1);
}

function _outputLeafNode($icon, $line, $description) {
	return 'N'.
	     sprintf('%08s', $icon).
	     sprintf('%08s', $line).
	     sprintf('%04s', strlen(trim($description))).
	     trim($description)."\n";
}

function _outputIncreaseLevel() {
	return 'I'."\n";
}

function _outputDecreaseLevel() {
	return 'D'."\n";
}

function _outputExit() {
	return 'X'."\n";
}

function array_peek($array) {
	if (!isset($array[count($array)-1])) return null;
	return $array[count($array)-1];
}

function strip_comment($x) {
	if (substr($x, 0, 1) == '#') return trim(substr($x, 1));
	if (substr($x, 0, 2) == '//') return trim(substr($x, 2));
	if (substr($x, 0, 2) == '/*') return trim(substr($x, 2, strlen($x)-4));
}


// TODO: hallo
# TODO: xxx
