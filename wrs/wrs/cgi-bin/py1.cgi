#!/usr/bin/python2.7
import zlib, cgitb, os

## The following is purely to help with debugging
cgitb.enable()

def resolveFile(filename):
      return '/data/' + filename

print("Content-type: application/warc")
print("\n")
obj = zlib.decompressobj(16 + zlib.MAX_WBITS)
filename = os.environ['REQUEST_URI'].split('/')[-1]
offset = int(os.environ['HTTP_RANGE'].split('-')[0])
with open(resolveFile(filename)) as fin:
    fin.seek(offset)
    while True:
        data = fin.read(1024 * 1024)
        if data == '':
            break
        print(obj.decompress(data))

