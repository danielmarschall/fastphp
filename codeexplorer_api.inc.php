<?php

define('SIGNAL_END_OF_TRANSMISSION', chr(1).chr(2).chr(3).chr(4).chr(5).chr(6).chr(7).chr(8));
define('SIGNAL_TERMINATE',           chr(8).chr(7).chr(6).chr(5).chr(4).chr(3).chr(2).chr(1));

class FastPHPExitSignalReceivedException extends Exception {

}

abstract class FastPHPIcon {
	private $type;          // arbitary identifier
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

	public function reset() {
		$this->type          = null;
		$this->visibility    = 3;
		$this->abstractFinal = '';
		$this->static        = false;
	}

	public function __construct() {
		$this->reset();
	}

	public abstract function imageIndex();
}

class FastPHPReader {
	public static function readCodeFromEditor() {
		$lines = array();
		while ($f = fgets(STDIN)){
			if (trim($f) == SIGNAL_END_OF_TRANSMISSION) break;

			// Signal to terminate the code explorer
			if (trim($f) == SIGNAL_TERMINATE) {
				 throw new FastPHPExitSignalReceivedException();
			}

			$lines[] = $f;
		}
		return implode("", $lines);
	}
}

class FastPHPWriter {

	public static function outputLeafNode(/*FastPHPIcon*/ $icon, /*int*/ $lineNo, /*string*/ $description) {
		$iconImageIndex = is_null($icon) ? -1 : $icon->imageIndex();
		echo 'N'.($iconImageIndex == -1 ? '____' : sprintf('%04s', $iconImageIndex)).
		         sprintf('%08s', $lineNo).
		         sprintf('%04s', strlen(trim($description))).
		         trim($description).
		         "\n";
	}

	public static function outputIncreaseLevel() {
		echo "I\n";
	}

	public static function outputDecreaseLevel() {
		echo "D\n";
	}

	public static function outputExit() {
		echo "X\n";
	}

	public static function signalOutputEnd() {
		echo "\n".SIGNAL_END_OF_TRANSMISSION."\n";
	}

	public static function outputHeader() {
		echo "FAST100!";
	}

}
