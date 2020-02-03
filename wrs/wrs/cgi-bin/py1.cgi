#!/usr/bin/python2.7
import zlib, cgitb, os

## The following is purely to help with debugging
cgitb.enable()

def resolveFile(filename):
      return '/data/' + filename

def onError(returnCode, message):
    print ("Status: " + returnCode)
    print ("Content-Type: text/html\r\n")
    print(message)


obj = zlib.decompressobj(16 + zlib.MAX_WBITS)
filename = os.environ['REQUEST_URI'].split('/')[-1]
offset = int(os.environ['HTTP_RANGE'].split('-')[0].strip('bytes='))
## TODO check that range header exists and is specified in bytes. Otherwise return a 416.
in_body = False
try:
    with open(resolveFile(filename)) as fin:
        fin.seek(offset) ## TODO check try/excpet that this is not larger than the file
        while True:
            data = fin.read(1024 * 1024)
            if data == '':
                break
            try:
                decompress_data = obj.decompress(data)
                if not(in_body):
                    print("Content-type: application/warc\r\n")
                    in_body = True
                print(decompress_data)
            except zlib.error as e:
                onError("416 Requested Range Not Satisfiable", "Invalid offset: " + filename + ":" + str(offset))
except IOError as e:
    onError("404 Not Found", "Could not find file " + filename)



