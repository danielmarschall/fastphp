<?php

// TODO: show full signature of each element?

error_reporting(0);

require_once __DIR__ . '/codeexplorer_api.inc.php';

define('ICON_TYPE_FUNCTION',     1);
define('ICON_TYPE_CONSTRUCTOR',  2);
define('ICON_TYPE_DESTRUCTOR',   3);
define('ICON_TYPE_MAGICMETHOD',  4);
define('ICON_TYPE_CLASS',        5);
define('ICON_TYPE_TRAIT',        6);
define('ICON_TYPE_INTERFACE',    7);
define('ICON_TYPE_VAR',          8);
define('ICON_TYPE_CONST',        9);
define('ICON_TYPE_TODO',        10);
define('ICON_TYPE_ERROR',       11);

class MyFastPHPIcon extends FastPHPIcon {

	public function imageIndex() {
		     if (($this->getType() == ICON_TYPE_CLASS)                               && (!$this->isAbstract())) return  0; // class
		else if (($this->getType() == ICON_TYPE_CLASS)                               && ( $this->isAbstract())) return  1; // abstract class
		else if (($this->getType() == ICON_TYPE_INTERFACE)                                                    ) return  2; // interface
		else if (($this->getType() == ICON_TYPE_TRAIT)                                                        ) return  3; // trait
		else if (($this->getType() == ICON_TYPE_CONST)     && ($this->isPrivate())                            ) return  4; // private const
		else if (($this->getType() == ICON_TYPE_VAR)       && ($this->isPrivate())                            ) return  5; // private var
		else if (($this->isMethod())                       && ($this->isPrivate())   && (!$this->isAbstract())) return  6; // private function
		else if (($this->isMethod())                       && ($this->isPrivate())   && ( $this->isAbstract())) return  7; // private abstract function
		else if (($this->getType() == ICON_TYPE_CONST)     && ($this->isProtected())                          ) return  8; // protected const
		else if (($this->getType() == ICON_TYPE_VAR)       && ($this->isProtected())                          ) return  9; // protected var
		else if (($this->isMethod())                       && ($this->isProtected()) && (!$this->isAbstract())) return 10; // protected function
		else if (($this->isMethod())                       && ($this->isProtected()) && ( $this->isAbstract())) return 11; // protected abstract function
		else if (($this->getType() == ICON_TYPE_CONST)     && ($this->isPublic())                             ) return 12; // public const
		else if (($this->getType() == ICON_TYPE_VAR)       && ($this->isPublic())                             ) return 13; // public var
		else if (($this->isMethod())                       && ($this->isPublic())    && (!$this->isAbstract())) return 14; // public function
		else if (($this->isMethod())                       && ($this->isPublic())    && ( $this->isAbstract())) return 15; // public abstract function
		else if (($this->getType() == ICON_TYPE_TODO)                                                         ) return 16; // To-Do comment
		else                                                                                                    return -1;
	}

	public function isMethod() {
		return (($this->getType() == ICON_TYPE_FUNCTION)    ||
		        ($this->getType() == ICON_TYPE_CONSTRUCTOR) ||
		        ($this->getType() == ICON_TYPE_DESTRUCTOR)  ||
		        ($this->getType() == ICON_TYPE_MAGICMETHOD));
	}

}

class MyFastPHPCodeExplorer {

	public function handle($code) {
		// Quick'n'Dirty fix to correctly parse the line
		// test(XYZ::class)
		$code = str_replace('::class', '', $code);

		// Quick'n'Dirty fix to correctly parse the line
		// $verify=file_get_contents("https://www.google.com/recaptcha/api/siteverify?secret={$secret}&response={$response}");
		$code = str_replace('{$', '{', $code);

		// Quick'n'Dirty fix to correctly parse the line
		// $handler = function(MqttClient $client, string $topic, string $message, int $qualityOfService, bool $retained) use (&$msg_count) {};
		$code = preg_replace('@function\s*\\(@is', '(', $code);

		$token = token_get_all($code);
		$wait_function = false;
		$wait_const = false;
		$wait_class = false;
		$wait_trait = false;
		$icon = new MyFastPHPIcon();
		$wait_interface = false;
		$wait_abstract_func_list_end = false;
		$levelAry = array();
		$dep = 0;
		$insideFuncAry = array();

		if (!$token) {
			$icon->setType(ICON_TYPE_ERROR);
			FastPHPWriter::outputLeafNode($icon, 0, 'SYNTAX ERROR');
		}

		foreach ($token as $data) {
			if ($data == '{') $dep++;
			if ($data == '}') {
				$dep--;
				if ((count($levelAry) > 0) && (self::array_peek($levelAry) == $dep)) {
					array_pop($levelAry);
					FastPHPWriter::outputDecreaseLevel();
				}
				if ((count($insideFuncAry) > 0) && (self::array_peek($insideFuncAry) == $dep)) {
					array_pop($insideFuncAry);
				}
			}

			$token = (!is_array($data)) ? null : $data[0];
			$value = (!is_array($data)) ? null : $data[1];
			$line  = (!is_array($data)) ? null : $data[2];

			if ($value == '${') $dep++; // TODO: "${...}" ??? "{$...}" ???

			if ($wait_function && ($data == '{')) {
				$wait_function = false; // Anonymous functions do not have a name
			}

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
				FastPHPWriter::outputLeafNode($icon, $line, $desc);
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
				FastPHPWriter::outputLeafNode($icon, $line, $desc);
				$icon->reset();

				FastPHPWriter::outputIncreaseLevel();
			}

			if ($wait_trait && ($token == T_STRING)) {
				$desc = "Trait $value\n";
				$wait_trait = false;
				$levelAry[] = $dep;

				$icon->setType(ICON_TYPE_TRAIT);
				FastPHPWriter::outputLeafNode($icon, $line, $desc);
				$icon->reset();

				FastPHPWriter::outputIncreaseLevel();
			}

			if ($wait_interface && ($token == T_STRING)) {
				$desc = "Interface $value\n";
				$wait_interface = false;
				$levelAry[] = $dep;

				$icon->setType(ICON_TYPE_INTERFACE);
				FastPHPWriter::outputLeafNode($icon, $line, $desc);
				$icon->reset();

				FastPHPWriter::outputIncreaseLevel();
			}

			if ($wait_const && ($token == T_STRING)) {
				$desc = "const $value\n";
				$wait_const = false;

				$icon->setType(ICON_TYPE_CONST);
				FastPHPWriter::outputLeafNode($icon, $line, $desc);
				$icon->reset();
			}

			if ((!$wait_abstract_func_list_end) && (count($levelAry) > 0) && (count($insideFuncAry) == 0) && ($token == T_VARIABLE)) {
				$desc = "$value\n";

				$icon->setType(ICON_TYPE_VAR);
				FastPHPWriter::outputLeafNode($icon, $line, $desc);
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

			if (($token == T_COMMENT) && self::isToDoDescription($value)) {
				$comment_lines = explode("\n", trim($value));
				foreach ($comment_lines as $line_no => $comment_line) {
					if (self::isToDoDescription($comment_line)) {
						// Because a To-Do-entry can stand everywhere (e.g. between a "private" and a "function" keyword)
						// we shall not alter the $icon instance
						$todoIcon = clone $icon;
						$todoIcon->setType(ICON_TYPE_TODO);
						FastPHPWriter::outputLeafNode($todoIcon, $line+$line_no, self::stripComment($comment_line));
						unset($todoIcon);
					}
				}
			}
		}
	}

	private static function isToDoDescription($comment) {
		return ((stripos($comment, 'TODO')   !== false) ||
		        (stripos($comment, 'BUGBUG') !== false) ||
		        (stripos($comment, 'FIXME')  !== false) ||
		        (stripos($comment, 'XXX')    !== false));
	}

	private static function stripComment($x) {
		$x = trim($x);
		if (substr($x, 0, 1) == '#') return trim(substr($x, 1));
		if (substr($x, 0, 2) == '//') return trim(substr($x, 2));
		if (substr($x, 0, 2) == '/*') return trim(substr($x, 2, strlen($x)-4));
		return $x;
	}


	private static /*final*/ function array_peek($array) {
		if (!isset($array[count($array)-1])) return null;
		return $array[count($array)-1];
	}
}

$parser = new MyFastPHPCodeExplorer();
while (true) {
	try {
		$code = FastPHPReader::readCodeFromEditor();
	} catch (FastPHPExitSignalReceivedException $e) {
		die();
	}
	FastPHPWriter::outputHeader();
	$parser->handle($code);
	FastPHPWriter::outputExit();
	FastPHPWriter::signalOutputEnd();
	sleep(1);
}
