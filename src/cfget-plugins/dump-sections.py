# Dump Sections from a config file
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
def dump_sections(cfget, outfd, paths):
	"""
	Dump sections (top level keys according to the current root)
	"""
	sections = {}
	for key, value in cfget.iteritems(paths):
		pos = key.find('/')
		if pos > -1:
			sect = key[:pos]
			if sect not in sections:
				sections[sect] = True
				print >>outfd, '%s' % (sect)

def init(db):
	"""
	Register the dumper
	"""
	db.add_dumper('sections', dump_sections)
