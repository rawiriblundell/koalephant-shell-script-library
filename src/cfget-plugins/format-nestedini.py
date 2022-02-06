# Parse a 'nested' INI format file
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

import re

def parse_nested_ini_file(pathname):
	"""
	Parse a configuration file containing nested ini values foo[bar] = baz
	"""
	RE_EMPTY = re.compile(r"^\s*(?:[#;].*)?$")
	RE_SECTION = re.compile(r"^\s*\[([^\]]+)\]\s*$")
	RE_VALUE = re.compile(r"^\s*([^=]+)=(.*)$")
	RE_KEYED_VALUE = re.compile(r"^\s*([^[]+)\[([^\]]*)\]\s*=(.*)$")

	integer_keys = {}

	section = None
	for lineno, line in enumerate(open(pathname)):
		if RE_EMPTY.match(line): continue
		mo = RE_SECTION.match(line)
		if mo:
			section = mo.group(1).lower().strip()
			continue
		mo = RE_KEYED_VALUE.match(line)
		if mo:
			key, subkey, value = mo.group(1, 2, 3)

			if section is None:
				path = key.strip().lower()
			else:
				path = section + "/" + key.strip().lower()

			if len(subkey.strip()) == 0:
				if integer_keys.has_key(path):
					integer_keys[path] += 1
				else:
					integer_keys[path] = 0

				path += "/" + str(integer_keys[path])
			else:
				path += "/" + subkey.strip().lower()

			value = value.strip()
			if value:
				yield path, value
			else:
				yield path, None
			continue
		mo = RE_VALUE.match(line)
		if mo:
			key, value = mo.group(1, 2)
			if section is None:
				path = key.strip().lower()
			else:
				path = section + "/" + key.strip().lower()
			value = value.strip()
			if value:
				yield path, value
			else:
				yield path, None
		else:
			raise cfget.ParseError(pathname, lineno+1, "line not a comment, and not in the form [section]; key[subkey]=value; key[]=value or key=value")


def init(db):
	"""
	Register the dumper
	"""
	db.add_format('nestedini', parse_nested_ini_file)
