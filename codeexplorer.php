<?php

// TODO: show full signature of each element?

error_reporting(0);

define('ICON_TYPE_FUNCTION',       'FUN');
define('ICON_TYPE_CONSTRUCTOR',    'CST');
define('ICON_TYPE_DESTRUCTOR',     'DST');
define('ICON_TYPE_MAGICMETHOD',    'MAG');
define('ICON_TYPE_CLASS',          'CLS');
define('ICON_TYPE_TRAIT',          'TRA');
define('ICON_TYPE_INTERFACE',      'INT');
define('ICON_TYPE_VAR',            'VAR');
define('ICON_TYPE_CONST',          'CON');
define('ICON_TYPE_TODO',           'TDO');
define('ICON_TYPE_ERROR',          'ERR');

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
		echo _outputLeafNode(ICON_TYPE_ERROR.implode('', $icon_add_flags), 1, 'SYNTAX ERROR');
	}
	
	$wait_function = false;
	$wait_class = false;
	$wait_trait = false;
	$wait_interface = false;
	$wait_abstract_func_list_end = false;
	$levelAry = array();
	$icon_add_flags = array('_', '_', '_');
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
			if ($icon_add_flags[1] == 'A') {
				$desc = "abstract function $value()";
				$wait_abstract_func_list_end = true;
			} else {
				$desc = "function $value()";
				$insideFuncAry[] = $dep;
			}

			if ($value == '__construct') { // TODO: auch eine methode mit dem namen der klasse soll eine konstruktor sein
				echo _outputLeafNode(ICON_TYPE_CONSTRUCTOR.implode('', $icon_add_flags), $line, $desc);
			} else if ($value == '__destruct') {
				echo _outputLeafNode(ICON_TYPE_DESTRUCTOR.implode('', $icon_add_flags), $line, $desc);
			} else if (substr($value, 0, 2) == '__') {
				echo _outputLeafNode(ICON_TYPE_MAGICMETHOD.implode('', $icon_add_flags), $line, $desc);
			} else {
				echo _outputLeafNode(ICON_TYPE_FUNCTION.implode('', $icon_add_flags), $line, $desc);
			}

			$icon_add_flags = array('_', '_', '_');
		}

		if ($wait_class && ($token == T_STRING)) {
                        if ($icon_add_flags[1] == 'A') {
				$desc = "abstract class $value\n";
			} else {
				$desc = "class $value\n";
			}
			$wait_class = false;
			$levelAry[] = $dep;

			echo _outputLeafNode(ICON_TYPE_CLASS.implode('', $icon_add_flags), $line, $desc);
			$icon_add_flags = array('_', '_', '_');

			echo _outputIncreaseLevel();
		}

		if ($wait_trait && ($token == T_STRING)) {
			$desc = "Trait $value\n";
			$wait_trait = false;
			$levelAry[] = $dep;

			echo _outputLeafNode(ICON_TYPE_TRAIT.implode('', $icon_add_flags), $line, $desc);
			$icon_add_flags = array('_', '_', '_');

			echo _outputIncreaseLevel();
		}

		if ($wait_interface && ($token == T_STRING)) {
			$desc = "Interface $value\n";
			$wait_interface = false;
			$levelAry[] = $dep;

			echo _outputLeafNode(ICON_TYPE_INTERFACE.implode('', $icon_add_flags), $line, $desc);
			$icon_add_flags = array('_', '_', '_');

			echo _outputIncreaseLevel();
		}

		if ($wait_const && ($token == T_STRING)) {
			$desc = "const $value\n";
			$wait_const = false;

			echo _outputLeafNode(ICON_TYPE_CONST.implode('', $icon_add_flags), $line, $desc);
			$icon_add_flags = array('_', '_', '_');
		}

		if ((!$wait_abstract_func_list_end) && (count($levelAry) > 0) && (count($insideFuncAry) == 0) && ($token == T_VARIABLE)) {
			$desc = "$value\n";

			echo _outputLeafNode(ICON_TYPE_VAR.implode('', $icon_add_flags), $line, $desc);
			$icon_add_flags = array('_', '_', '_');
		}

		if ($token == T_PRIVATE)   $icon_add_flags[0] = '1';
		if ($token == T_PROTECTED) $icon_add_flags[0] = '2';
		if ($token == T_PUBLIC)    $icon_add_flags[0] = '3';
		if ($token == T_ABSTRACT)  $icon_add_flags[1] = 'A';
		if ($token == T_FINAL)     $icon_add_flags[1] = 'F';
		if ($token == T_STATIC)    $icon_add_flags[2] = 'S';

		if (($data == ';') || ($data == '{') || ($data == '}')) {
			$wait_abstract_func_list_end = false;
			$icon_add_flags = array('_', '_', '_');
		}

		if ($token == T_FUNCTION) {
			$wait_function = true;
		}
		if ($token == T_CLASS) {
			$wait_class = true;
			$dep = 0;
		}
		if ($token == T_INTERFACE) {
			$wait_interface = true;
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
				echo _outputLeafNode(ICON_TYPE_TODO.implode('', $icon_add_flags), $line, strip_comment($value));
			}
		}
	}
	
	echo _outputExit();

	echo chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8);

	sleep(1);
}

function _iconCodeToIndex($icon) {
	$typ = substr($icon, 0, 3);

	if ($icon[3] == '_') $icon[3] = '3'; // public is default visibility

	if (($typ == 'MAG') || ($typ == 'CST') || ($typ == 'DST')) {
		$typ = 'FUN';
	} else if ($typ == 'INT') {
		$typ = 'CLS';
		$icon[4] = 'A';
	}

	     if (($typ == 'CLS')                      && ($icon[4] != 'A')) return  0;
	else if (($typ == 'CLS')                      && ($icon[4] == 'A')) return  1;
	else if (($typ == 'TRA')                                          ) return  2;
	else if (($typ == 'CON') && ($icon[3] == '1')                     ) return  3;
	else if (($typ == 'VAR') && ($icon[3] == '1')                     ) return  4;
	else if (($typ == 'FUN') && ($icon[3] == '1') && ($icon[4] != 'A')) return  5;
	else if (($typ == 'FUN') && ($icon[3] == '1') && ($icon[4] == 'A')) return  6;
	else if (($typ == 'CON') && ($icon[3] == '2')                     ) return  7;
	else if (($typ == 'VAR') && ($icon[3] == '2')                     ) return  8;
	else if (($typ == 'FUN') && ($icon[3] == '2') && ($icon[4] != 'A')) return  9;
	else if (($typ == 'FUN') && ($icon[3] == '2') && ($icon[4] == 'A')) return 10;
	else if (($typ == 'CON') && ($icon[3] == '3')                     ) return 11;
	else if (($typ == 'VAR') && ($icon[3] == '3')                     ) return 12;
	else if (($typ == 'FUN') && ($icon[3] == '3') && ($icon[4] != 'A')) return 13;
	else if (($typ == 'FUN') && ($icon[3] == '3') && ($icon[4] == 'A')) return 14;
	else if (($typ == 'TDO')                                          ) return 15;
	else                                                                return -1;
}

function _outputLeafNode($icon, $line, $description) {
	$imageindex = _iconCodeToIndex($icon);
	return 'N'.($imageindex == -1 ? '____' : sprintf('%04s', $imageindex)).
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

