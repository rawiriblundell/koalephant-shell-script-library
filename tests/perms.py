import os
import sys

stat = os.stat(sys.argv[1])

print oct(stat.st_mode)[3:], stat.st_uid, stat.st_gid
