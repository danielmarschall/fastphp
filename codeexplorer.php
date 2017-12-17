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
	$code = FastNodeReader::readCodeFromEditor();

	$x = token_get_all($code);
	$wait_function = false;
	$wait_class = false;
	$wait_trait = false;
	$wait_interface = false;
	$wait_abstract_func_list_end = false;
	$levelAry = array();
	$icon = new FastPHPIcon();
	$dep = 0;
	$insideFuncAry = array();

	echo FastNodeWriter::outputHeader();

	if (!$x) {
		$icon->setType(ICON_TYPE_ERROR);
		echo FastNodeWriter::outputLeafNode($icon, 1, 'SYNTAX ERROR');
	}

	foreach ($x as $n => $data) {
		if ($data == '{') $dep++;
		if ($data == '}') {
			$dep--;
			if ((count($levelAry) > 0) && (array_peek($levelAry) == $dep)) {
				array_pop($levelAry);
				echo FastNodeWriter::outputDecreaseLevel();
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
			if ($icon->isAbstract()) {
				$desc = "abstract function $value()";
				$wait_abstract_func_list_end = true;
			} else {
				$desc = "function $value()";
				$insideFuncAry[] = $dep;
			}

			if ($value == '__construct') { // TODO: auch eine methode mit dem namen der klasse soll eine konstruktor sein
                                $icon->setType(ICON_TYPE_CONSTRUCTOR);
			} else if ($value == '__destruct') {
                                $icon->setType(ICON_TYPE_DESTRUCTOR);
			} else if (substr($value, 0, 2) == '__') {
                                $icon->setType(ICON_TYPE_MAGICMETHOD);
			} else {
                                $icon->setType(ICON_TYPE_FUNCTION);
			}
			echo FastNodeWriter::outputLeafNode($icon, $line, $desc);
			$icon->reset();
		}

		if ($wait_class && ($token == T_STRING)) {
                        if ($icon->isAbstract()) {
				$desc = "Abstract Class $value\n";
			} else {
				$desc = "Class $value\n";
			}
			$wait_class = false;
			$levelAry[] = $dep;

			$icon->setType(ICON_TYPE_CLASS);
			echo FastNodeWriter::outputLeafNode($icon, $line, $desc);
			$icon->reset();

			echo FastNodeWriter::outputIncreaseLevel();
		}

		if ($wait_trait && ($token == T_STRING)) {
			$desc = "Trait $value\n";
			$wait_trait = false;
			$levelAry[] = $dep;

			$icon->setType(ICON_TYPE_TRAIT);
			echo FastNodeWriter::outputLeafNode($icon, $line, $desc);
			$icon->reset();

			echo FastNodeWriter::outputIncreaseLevel();
		}

		if ($wait_interface && ($token == T_STRING)) {
			$desc = "Interface $value\n";
			$wait_interface = false;
			$levelAry[] = $dep;

                        $icon->setType(ICON_TYPE_INTERFACE);
			echo FastNodeWriter::outputLeafNode($icon, $line, $desc);
			$icon->reset();

			echo FastNodeWriter::outputIncreaseLevel();
		}

		if ($wait_const && ($token == T_STRING)) {
			$desc = "const $value\n";
			$wait_const = false;

			$icon->setType(ICON_TYPE_CONST);
			echo FastNodeWriter::outputLeafNode($icon, $line, $desc);
			$icon->reset();
		}

		if ((!$wait_abstract_func_list_end) && (count($levelAry) > 0) && (count($insideFuncAry) == 0) && ($token == T_VARIABLE)) {
			$desc = "$value\n";

			$icon->setType(ICON_TYPE_VAR);
			echo FastNodeWriter::outputLeafNode($icon, $line, $desc);
			$icon->reset();
		}

		if ($token == T_PRIVATE)   $icon->setPrivate();
		if ($token == T_PROTECTED) $icon->setProtected();
		if ($token == T_PUBLIC)    $icon->setPublic();
		if ($token == T_ABSTRACT)  $icon->setAbstract();
		if ($token == T_FINAL)     $icon->setFinal();
		if ($token == T_STATIC)    $icon->setStatic();

		if (($data == ';') || ($data == '{') || ($data == '}')) {
			$wait_abstract_func_list_end = false;
			$icon->reset();
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

		if (($token == T_COMMENT) && _isToDoDescription($value)) {
			// Because a TO-DO-entry can stand everywhere (e.g. between a "private" and a "function")
			// we shall not alter the $icon instance
			$todoIcon = clone $icon;
			$todoIcon->setType(ICON_TYPE_TODO);
			echo FastNodeWriter::outputLeafNode($todoIcon, $line, strip_comment($value));
		}
	}
	
	echo FastNodeWriter::outputExit();

	echo FastNodeWriter::signalOutputEnd();

	sleep(1);
}

function _isToDoDescription($comment) {
	return ((stripos($value, 'TODO')   !== false) ||
	        (stripos($value, 'BUGBUG') !== false) ||
	        (stripos($value, 'FIXME')  !== false) ||
	        (stripos($value, 'XXX')    !== false));
}

function _iconCodeToIndex(/* FastPHPIcon */ $icon) {
	     if (($icon->getType() == ICON_TYPE_CLASS)                               && (!$icon->isAbstract())) return  0; // class
	else if (($icon->getType() == ICON_TYPE_CLASS)                               && ( $icon->isAbstract())) return  1; // abstract class
	else if (($icon->getType() == ICON_TYPE_INTERFACE)                                                    ) return  2; // interface
	else if (($icon->getType() == ICON_TYPE_TRAIT)                                                        ) return  3; // trait
	else if (($icon->getType() == ICON_TYPE_CONST)     && ($icon->isPrivate())                            ) return  4; // private const
	else if (($icon->getType() == ICON_TYPE_VAR)       && ($icon->isPrivate())                            ) return  5; // private var
	else if (($icon->isMethod())                       && ($icon->isPrivate())   && (!$icon->isAbstract())) return  6; // private function
	else if (($icon->isMethod())                       && ($icon->isPrivate())   && ( $icon->isAbstract())) return  7; // private abstract function
	else if (($icon->getType() == ICON_TYPE_CONST)     && ($icon->isProtected())                          ) return  8; // protected const
	else if (($icon->getType() == ICON_TYPE_VAR)       && ($icon->isProtected())                          ) return  9; // protected var
	else if (($icon->isMethod())                       && ($icon->isProtected()) && (!$icon->isAbstract())) return 10; // protected function
	else if (($icon->isMethod())                       && ($icon->isProtected()) && ( $icon->isAbstract())) return 11; // protected abstract function
	else if (($icon->getType() == ICON_TYPE_CONST)     && ($icon->isPublic())                             ) return 12; // public const
	else if (($icon->getType() == ICON_TYPE_VAR)       && ($icon->isPublic())                             ) return 13; // public var
	else if (($icon->isMethod())                       && ($icon->isPublic())    && (!$icon->isAbstract())) return 14; // public function
	else if (($icon->isMethod())                       && ($icon->isPublic())    && ( $icon->isAbstract())) return 15; // public abstract function
	else if (($icon->getType() == ICON_TYPE_TODO)                                                         ) return 16; // ToDo comment
	else                                                                                                    return -1;
}

class FastPHPIcon {
	private $type;          // ICON_TYPE_*
	private $visibility;    // 1=private, 2=protected, 3=public(default)
	private $abstractFinal; // 'A', 'F', ''(default)
	private $static;        // true, false(default)

	public function setType($type) {
		$this->type = $type;
	}
	public function getType() {
		return $this->type;
	}

	public function setAbstract() {
		$this->abstractFinal = 'A';
	}
	public function isAbstract() {
		return $this->abstractFinal == 'A';
	}

	public function setFinal() {
		$this->abstractFinal = 'F';
	}
	public function isFinal() {
		return $this->abstractFinal == 'F';
	}

	public function setStatic() {
		$this->static = true;
	}
	public function isStatic() {
		return $this->static;
	}

	public function setPrivate() {
		$this->visibility = 1;
	}
	public function isPrivate() {
		return $this->visibility == 1;
	}

	public function setProtected() {
		$this->visibility = 2;
	}
	public function isProtected() {
		return $this->visibility == 2;
	}

	public function setPublic() {
		$this->visibility = 3;
	}
	public function isPublic() {
		return $this->visibility == 3;
	}

	public function isMethod() {
		return (($this->type == ICON_TYPE_FUNCTION)    ||
                        ($this->type == ICON_TYPE_CONSTRUCTOR) ||
                        ($this->type == ICON_TYPE_DESTRUCTOR)  ||
                        ($this->type == ICON_TYPE_MAGICMETHOD));
	}

	public function reset() {
		$this->type          = null;
		$this->visibility    = 3;
		$this->abstractFinal = '';
		$this->static        = false;
	}

	public function __construct() {
		$this->reset();
	}
}

class FastNodeReader {
	public static function readCodeFromEditor() {
		$lines = array();
		while ($f = fgets(STDIN)){
			if (trim($f) == chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8)) break;

			// Signal to terminate the code explorer
			if (trim($f) == chr(8).chr(7).chr(6).chr(5).chr(4).chr(3).chr(2).chr(1)) die();

			$lines[] = $f;
		}
		return implode("", $lines);
	}
}

class FastNodeWriter {

	public static function outputLeafNode(/* FastPHPIcon */ $icon, $lineNo, $description) {
		$imageindex = _iconCodeToIndex($icon);
		return 'N'.($imageindex == -1 ? '____' : sprintf('%04s', $imageindex)).
		           sprintf('%08s', $lineNo).
		           sprintf('%04s', strlen(trim($description))).
		           trim($description).
			   "\n";
	}

	public static function outputIncreaseLevel() {
		return 'I'."\n";
	}

	public static function outputDecreaseLevel() {
		return 'D'."\n";
	}

	public static function outputExit() {
		return 'X'."\n";
	}

	public static function signalOutputEnd() {
		return chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8);
	}

	public static function outputHeader() {
		return "FAST100!";
	}

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

