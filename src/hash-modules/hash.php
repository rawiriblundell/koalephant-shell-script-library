<?php
define('OP_AVAIL', 'avail');
define('OP_ALGOS', 'algos');
define('OP_VERIFY', 'verify');
define('OP_GENERATE', 'generate');

function avail($algo) {
	if (! extension_loaded('hash')) {
		/** @noinspection ForgottenDebugOutputInspection */
		error_log('Hash extension not loaded');
		exit(1);
	}
	if (! in_array($algo, hash_algos(), true)) {
		/** @noinspection ForgottenDebugOutputInspection */
		error_log('Hash algo not supported: ' . $algo);
		exit(1);
	}

	exit(0);
}

function algos() {
	return implode(' ', hash_algos());
}

function generate($algo, $file) {
	if ($file === '-') {
		return hash($algo, file_get_contents('php://stdin'));
	}
	if (file_exists($file)) {
		return hash_file($algo, $file);
	}

	exit(2);
}

function verify($algo, $file, $hash) {
	return hash_equals(
		$hash,
		generate($algo, $file)
	);
}

function min_args(array $names) {
	$count = count($names);
	if ($_SERVER['argc'] < ($count + 1)) {
		fwrite(STDERR, sprintf('Minimum %d arguments required: %s'. PHP_EOL, $count, implode(' ', $names)));
		exit(2);
	}
}

array_shift($_SERVER['argv']);
min_args(['op']);
define('OPERATION',array_shift($_SERVER['argv']));

switch (OPERATION) {
	case OP_AVAIL:
		min_args(['op', 'algo']);
		call_user_func_array('avail', $_SERVER['argv']);
		break;

	case OP_ALGOS:
		echo algos();
		break;

	case OP_GENERATE:
		min_args(['op', 'algo', 'file']);
		echo call_user_func_array('generate', $_SERVER['argv']);
	break;

	case OP_VERIFY:
		min_args(['op', 'algo', 'file', 'known-hash']);
		exit(call_user_func_array('verify', $_SERVER['argv']) ? 0 : 1);
	break;

	default:
		exit(1);
}
