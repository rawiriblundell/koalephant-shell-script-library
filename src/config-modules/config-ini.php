<?php
if ($_SERVER['argc'] < 1) {
	fwrite(STDERR, 'Minimum 1 arguments required: op' . PHP_EOL);
	exit(1);
}
define('OPERATION', $_SERVER['argv'][1]);
define('OP_AVAIL', 'avail');
define('OP_SECTIONS', 'sections');
define('OP_KEYS', 'keys');
define('OP_READ', 'read');

function get_array(array $keyPath) {
	$arr = parse_ini_file(CONFIG_FILE, true, INI_SCANNER_RAW);

	if (count($keyPath)) {
		while (count($keyPath) > 0) {
			$key = array_shift($keyPath);
			if (array_key_exists($key, $arr) && is_array($arr[$key])) {
				$arr = $arr[$key];
				continue;
			}

			return [];
		}
	}

	return $arr;
}

function get_offset_arg($offset) {

	$offset += 2;

	if ($_SERVER['argc'] > $offset) {
		return $_SERVER['argv'][$offset] ?: null;
	}

	return null;
}

function convert_to_array($root, $key) {
	return preg_split('#/#', "{$root}/${key}", -1, PREG_SPLIT_NO_EMPTY);
}

function get_keys(array $keyPath, $sectionMatch) {
	$keys = [];

	$iterator = static function (array $arr, $prefix = null) use (&$iterator, &$keys, $sectionMatch) {
		foreach ($arr as $k => $v) {

			if ($sectionMatch === is_array($v)) {
				$keys["{$prefix}{$k}"] = true;
			}
			if (!$sectionMatch && is_array($v)) {
				$iterator($v, "{$prefix}{$k}/");
			}
		}
	};

	$iterator(get_array($keyPath));


	echo implode(PHP_EOL, array_keys($keys)) . (count($keys) ? PHP_EOL : null);
}

function read_key(array $keyPath) {
	$key =  array_pop($keyPath);

	$arr = get_array($keyPath);

	if (array_key_exists($key, $arr)) {
		echo $arr[$key] . PHP_EOL;
		return;
	}

	exit(1);
}

function avail() {
	if (! function_exists('parse_ini_file')) {
		exit(1);
	}
	exit(0);
}

if (OPERATION === OP_AVAIL) {
	avail();
}

if ($_SERVER['argc'] < 2) {
	fwrite(STDERR, 'Minimum 1 arguments required: op' . PHP_EOL);
	exit(1);
}
define('CONFIG_FILE', $_SERVER['argv'][2]);

switch (OPERATION) {
	case OP_SECTIONS:
		get_keys(convert_to_array(get_offset_arg(1), null), true);
		break;

	case OP_KEYS:
		get_keys(convert_to_array(get_offset_arg(1), null), false);
		break;

	case OP_READ:
		read_key(convert_to_array(get_offset_arg(2), get_offset_arg(1)));
		break;

	default:
		exit(1);
}
