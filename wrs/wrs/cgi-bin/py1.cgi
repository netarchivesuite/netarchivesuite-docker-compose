#!/usr/bin/python2.7
import zlib, cgitb, os

## The following is purely to help with debugging
cgitb.enable()

def resolveFile(filename):
      return '/data/' + filename


obj = zlib.decompressobj(16 + zlib.MAX_WBITS)
filename = os.environ['REQUEST_URI'].split('/')[-1]
offset = int(os.environ['HTTP_RANGE'].split('-')[0].strip('bytes='))
## TODO check that range header i specified in bytes
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
                    print("Content-type: application/warc")
                    print("\n")
                    in_body = True
                print(decompress_data)
            except zlib.error as e:
                print ("Status: 416 Requested Range Not Satisfiable\r\n")
                print ("Content-Type: text/html\r\n\r\n")
                print("\n")
                print("Invalid offset: " + filename + ":" + str(offset))
except IOError as e:
    print ("Status: 404 Not Found\r\n")
    print ("Content-Type: text/html\r\n\r\n")
    print("\n")
    print("Could not find file " + filename)



