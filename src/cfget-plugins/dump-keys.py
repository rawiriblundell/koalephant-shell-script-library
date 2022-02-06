# Dump Keys from a config file
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
def dump_keys(cfget, outfd, paths):
	"""
	Dump keys
	"""
	for key, value in cfget.iteritems(paths):
		print >>outfd, '%s' % (key)

def init(db):
	"""
	Register the dumper
	"""
	db.add_dumper('keys', dump_keys)
