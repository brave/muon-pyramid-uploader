#!/usr/bin/env python
import os
import sys
os.system('7z a -r tmp.zip ' + os.environ['FILE_LIST'])
os.system('aws s3 cp tmp.zip ' + sys.argv[1] + '--acl public-read')
