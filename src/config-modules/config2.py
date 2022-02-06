import StringIO
import sys
from ConfigParser import RawConfigParser

config = RawConfigParser()
# Make sure names are handled in a case-sensitive manner
config.optionxform = str

# Handle ConfigParser's failure on section-less ini files
FAKE_SECTION_NAME = 'KOALEPHANT_CONFIG_PY_FAKE_HEADER'

op = sys.argv[1]

def sanitise_name(name, prefix, allowFake = False):
	name = name.replace('[', '/').replace(']', '')
	if prefix is not None and ((allowFake is True and name.find('/') == -1) or prefix != FAKE_SECTION_NAME):
		name = prefix + '/' + name

	return name


def get_section_name_output(name):
	offset = name.find('[')
	if offset == -1:
		return None

	return name[:offset]


def show_keys(root, prefix = False):
	if config.has_section(root):
		for name, value in config.items(root):
			print(sanitise_name(name, root if prefix else None))


def read_key(key):
	parts = key.split('/')

	if len(parts) == 2:
		if config.has_option(parts[0], parts[1]):
			print config.get(parts[0], parts[1])
			return 0
	else:
		section = parts[0]
		key = parts[1] + '[' + (']['.join(parts[2:])) + ']'

		if config.has_option(section, key):
			print config.get(section, key)
			return 0
	exit(1)


def write_key(key, value):
	parts = key.split('/')

	if not config.has_section(parts[0]):
		config.add_section(parts[0])

	if len(parts) == 2:
		config.set(parts[0], parts[1], value)
	else:
		config.set(parts[0], parts[1] + '[' + (']['.join(parts[2:])) + ']', value)


if op == 'avail':
	exit(0)

fileName = sys.argv[2]
configFile = open(fileName, 'r+' if op == 'write' else 'r')
ini = StringIO.StringIO('[' + FAKE_SECTION_NAME + ']\n' + configFile.read())
config.readfp(ini)

if op == 'sections':
	if len(sys.argv) >= 4 and len(sys.argv[3]) > 0:
		if config.has_section(sys.argv[3]):
			secNames = []
			for name, value in config.items(sys.argv[3]):
				name = get_section_name_output(name)
				if name is not None and name not in secNames:
					secNames.append(name)

			if len(secNames) > 0:
				print "\n".join(secNames)

	else:
		for name in config.sections():
			if name != FAKE_SECTION_NAME:
				print name

elif op == 'keys':
	if len(sys.argv) >= 4 and len(sys.argv[3]) > 0:
		show_keys(sys.argv[3])
	else:
		for section in config.sections():
			show_keys(section, section)

elif op == 'read':
	if len(sys.argv) >= 5 and len(sys.argv[4]) > 0:
		read_key(sanitise_name(sys.argv[3], sys.argv[4]))
	else:
		read_key(sanitise_name(sys.argv[3], FAKE_SECTION_NAME, True))

elif op == 'write':
	if len(sys.argv) >= 6 and len(sys.argv[5]) > 0:
		write_key(sanitise_name(sys.argv[3], sys.argv[5]), sys.argv[4])
	else:
		write_key(sanitise_name(sys.argv[3], FAKE_SECTION_NAME, True), sys.argv[4])

	tmpString = StringIO.StringIO()
	config.write(tmpString)
	tmpString.seek(0)
	configFile.seek(0)
	configFile.write(tmpString.read().replace('[' + FAKE_SECTION_NAME + ']\n', ''))
	configFile.close()
