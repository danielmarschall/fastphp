<?php

error_reporting(0);

define('ICON_ATTR_PRIVATE',             1);
define('ICON_ATTR_PROTECTED',           2);
define('ICON_ATTR_PUBLIC',              4);
define('ICON_ATTR_ABSTRACT',            8);
define('ICON_ATTR_STATIC',             16);

define('ICON_TYPE_FUNCTION',       'FUNC');
define('ICON_TYPE_CONSTRUCTOR',    'CSTR');
define('ICON_TYPE_DESTRUCTOR',     'DSTR');
define('ICON_TYPE_MAGICMETHOD',    'MGIC');
define('ICON_TYPE_CLASS',          'CLAS');
define('ICON_TYPE_TRAIT',          'TRAI');
define('ICON_TYPE_INTERFACE',      'INTF');
define('ICON_TYPE_TODO',           'TODO');
define('ICON_TYPE_ERROR',          'ERR!');
define('ICON_TYPE_VAR',            'VAR_');
define('ICON_TYPE_CONST',          'CONS');

define('ICON_TYPE_FOLDER',         'FOLD'); // unused (TODO: use for TODO)
define('ICON_TYPE_FILE',           'FILE'); // unused

while (true) {
	$lines = array();
	while ($f = fgets(STDIN)){
		if (trim($f) == chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8)) break;
		$lines[] = $f;
	}
	$code = implode("", $lines);

	echo "FAST100!\n";
	
	$x = token_get_all($code);
	
	if (!$x) {
		echo _outputLeafNode(ICON_TYPE_ERROR, 0, 1, 'SYNTAX ERROR');
	}
	
	$wait_function = false;
	$wait_class = false;
	$wait_trait = false;
	$wait_interface = false;
	$wait_abstract_func_list_end = false;
	$levelAry = array();
	$icon_add_flags = 0;
	$dep = 0;
	$insideFuncAry = array();

	foreach ($x as $n => $data) {
		if ($data == '{') $dep++;
		if ($data == '}') {
			$dep--;
			if ((count($levelAry) > 0) && (array_peek($levelAry) == $dep)) {
				array_pop($levelAry);
				echo _outputDecreaseLevel();
			}
			if ((count($insideFuncAry) > 0) && (array_peek($insideFuncAry) == $dep)) {
				array_pop($insideFuncAry);
			}
		}

		$token = (!is_array($data)) ? null : $data[0];
		$value = (!is_array($data)) ? null : $data[1];
		$line  = (!is_array($data)) ? null : $data[2];

		if ($wait_function && ($token == T_STRING)) {
			$wait_function = false;
                        if (($icon_add_flags & ICON_ATTR_ABSTRACT) == ICON_ATTR_ABSTRACT) {
				$desc = "abstract function $value()";
                                $wait_abstract_func_list_end = true;
			} else {
				$desc = "function $value()";
                        	$insideFuncAry[] = $dep;
			}
			$icon_add_flags = 0;

			if ($value == '__construct') { // TODO: auch eine methode mit dem namen der klasse soll eine konstruktor sein
				echo _outputLeafNode(ICON_TYPE_CONSTRUCTOR, $icon_add_flags, $line, $desc);
			} else if ($value == '__destruct') {
				echo _outputLeafNode(ICON_TYPE_DESTRUCTOR,  $icon_add_flags, $line, $desc);
			} else if (substr($value, 0, 2) == '__') {
				echo _outputLeafNode(ICON_TYPE_MAGICMETHOD, $icon_add_flags, $line, $desc);
			} else {
				echo _outputLeafNode(ICON_TYPE_FUNCTION,    $icon_add_flags, $line, $desc);
			}
		}

		if ($wait_class && ($token == T_STRING)) {
			$desc = "Class $value\n";
			$icon_add_flags = 0;
			$wait_class = false;
			$levelAry[] = $dep;

			echo _outputLeafNode(ICON_TYPE_CLASS, $icon_add_flags, $line, $desc);
                        echo _outputIncreaseLevel();
		}

		if ($wait_trait && ($token == T_STRING)) {
			$desc = "Trait $value\n";
			$icon_add_flags = 0;
			$wait_trait = false;
			$levelAry[] = $dep;

			echo _outputLeafNode(ICON_TYPE_TRAIT, $icon_add_flags, $line, $desc);
                        echo _outputIncreaseLevel();
		}

		if ($wait_interface && ($token == T_STRING)) {
			$desc = "Interface $value\n";
			$icon_add_flags = 0;
			$wait_interface = false;
			$levelAry[] = $dep;

			echo _outputLeafNode(ICON_TYPE_INTERFACE, $icon_add_flags, $line, $desc);
                        echo _outputIncreaseLevel();
		}

		if ($wait_const && ($token == T_STRING)) {
			$desc = "const $value\n";
			$icon_add_flags = 0;
			$wait_const = false;

			echo _outputLeafNode(ICON_TYPE_CONST, $icon_add_flags, $line, $desc);
		}

		if ((!$wait_abstract_func_list_end) && (count($levelAry) > 0) && (count($insideFuncAry) == 0) && ($token == T_VARIABLE)) {
			$desc = "$value\n";
			$icon_add_flags = 0;

			echo _outputLeafNode(ICON_TYPE_VAR, $icon_add_flags, $line, $desc);
		}

		if ($token == T_PRIVATE)   $icon_add_flags |= ICON_ATTR_PRIVATE;
		if ($token == T_PROTECTED) $icon_add_flags |= ICON_ATTR_PROTECTED;
		if ($token == T_PUBLIC)    $icon_add_flags |= ICON_ATTR_PUBLIC;
		if ($token == T_ABSTRACT)  $icon_add_flags |= ICON_ATTR_ABSTRACT;
		if ($token == T_STATIC)    $icon_add_flags |= ICON_ATTR_STATIC;

		if (($data == ';') || ($data == '{') || ($data == '}')) {
			$wait_abstract_func_list_end = false;
			$icon_add_flags = 0;
		}

		if ($token == T_FUNCTION) {
			$wait_function = true;
		}
		if ($token == T_CLASS) {
			$wait_class = true;
			$dep = 0;
		}
		if ($token == T_TRAIT) {
			$wait_trait = true;
			$dep = 0;
		}

		if ($token == T_CONST) {
			$wait_const = true;
		}

		if ($token == T_COMMENT) {
			if ((stripos($value, 'TODO')   !== false) ||
			    (stripos($value, 'BUGBUG') !== false) ||
			    (stripos($value, 'FIXME')  !== false) ||
			    (stripos($value, 'XXX')    !== false)) {
				echo _outputLeafNode(ICON_TYPE_TODO, 0, $line, strip_comment($value));
			}
		}
	}
	
	echo _outputExit();

	echo chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8);

	sleep(1);
}

function _outputLeafNode($iconType, $iconAttr, $line, $description) {
	return 'N'.str_pad($iconType, 4).
	           sprintf('%04s', $iconAttr).
	           sprintf('%08s', $line).
	           sprintf('%04s', strlen(trim($description))).
	           trim($description).
		   "\n";
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

