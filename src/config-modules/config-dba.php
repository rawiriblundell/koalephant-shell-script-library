<?php
define('OP_AVAIL', 'avail');
define('OP_SECTIONS', 'sections');
define('OP_KEYS', 'keys');
define('OP_READ', 'read');
define('OP_WRITE', 'write');

function open_handle() {
	return dba_open($_SERVER['argv'][2], OPERATION === OP_WRITE ? 'c' : 'r', 'inifile');
}

function get_offset_arg($offset) {

	$offset += 2;

	if ($_SERVER['argc'] > $offset) {
		return $_SERVER['argv'][$offset] ?: null;
	}

	return null;
}

function convert_to_brackets($root, $key) {
	$parts = preg_split('#/#', "{$root}/${key}", -1, PREG_SPLIT_NO_EMPTY);

	if (count($parts) === 0) {
		return null;
	}

	if ((string) $root === '' && count($parts) === 1) {
		return $parts[0];
	}

	foreach ($parts as $i => &$part) {
		if ($i !== 1) {
			$part = '[' . $part . ']';
		}
	}
	unset($part);

	return implode('', $parts);
}

function convert_to_slashes($key) {
	return trim(str_replace([']', '[', '//'], '/', $key), '/');
}

function get_matching_prefix($key, $prefix) {
	if ((string) $prefix !== '') {
		if (strpos($key, $prefix) === 0) {
			return substr($key, strlen($prefix));
		}

		return null;
	}

	return $key;
}

function get_section_name($key) {
	$key = ltrim($key, '[]');
	$section = substr($key, 0, strcspn($key, '[]'));

	if ($section !== $key) {
		return $section;
	}

	return null;
}

function get_key_name($key) {
	$lastChar = strlen($key) - 1;
	if (strpos($key, '[') === 0 && // starts with [
		strrpos($key, ']') === $lastChar && // ends with ]
		strpos($key, ']', 1) === $lastChar) { // no ] before the end
		return null;
	}

	return $key;
}

function get_keys($root, $sectionMatch) {
	$handle = open_handle();

	$key = dba_firstkey($handle);
	$sections = [];

	while ($key !== false) {

		$key = get_matching_prefix($key, $root);

		if ($key) {
			if ($sectionMatch) {
				$key = get_section_name($key);
			}
			else {
				$key = get_key_name($key);
			}

			if ($key) {
				$sections[convert_to_slashes($key)] = true;
			}
		}

		/** @noinspection SuspiciousAssignmentsInspection */
		$key = dba_nextkey($handle);
	}

	echo implode(PHP_EOL, array_keys($sections)) . (count($sections) ? PHP_EOL : null);
}

function read_key($key) {
	$handle = open_handle();

	if (dba_exists($key, $handle)) {
		echo dba_fetch($key, $handle) . PHP_EOL;
		return;
	}
	exit(1);
}

function write_key($key, $value) {
	$handle = open_handle();

	dba_replace($key, $value, $handle);
	dba_sync($handle);
}

function avail() {
	if (! function_exists('dba_handlers') || ! in_array('inifile', dba_handlers(), true)) {
		exit(1);
	}
	exit(0);
}

function min_args(array $names) {
	$count = count($names);
	if ($_SERVER['argc'] < ($count + 1)) {
		fwrite(STDERR, sprintf('Minimum %d arguments required: %s, %d given: %s'. PHP_EOL, $count, implode(' ', $names), $_SERVER['argc'], implode(' ', $_SERVER['argv'])));
		exit(1);
	}
}

min_args(['op']);
define('OPERATION',$_SERVER['argv'][1]);

switch (OPERATION) {
	case OP_AVAIL:
		avail();
		break;

	case OP_SECTIONS:
		min_args(['op', 'file']);
		get_keys(convert_to_brackets(get_offset_arg(1), null), true);
		break;

	case OP_KEYS:
		min_args(['op', 'file']);
		get_keys(convert_to_brackets(get_offset_arg(1), null), false);
		break;

	case OP_READ:
		min_args(['op', 'file', 'key']);
		read_key(convert_to_brackets(get_offset_arg(2), get_offset_arg(1)));
		break;

	case OP_WRITE:
		min_args(['op', 'file', 'key', 'value']);
		write_key(convert_to_brackets(get_offset_arg(3), get_offset_arg(1)), get_offset_arg(2));
		break;

	default:
		exit(1);
}
