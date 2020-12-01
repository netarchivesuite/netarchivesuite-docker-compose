#!/usr/bin/python2.7
import zlib, cgitb, cgi, os, subprocess, urllib, sys
from ConfigParser import SafeConfigParser

##
## TODO 's are reminders for the mature production implementation
##
class AbstractRecordService:

    def resolveFile(self, filename, filedir):
          raise Exception("resolveFile method not implemented")

    def onError(self, returnCode, message):
        print ("Status: " + returnCode)
        print ("Content-Type: text/html\r\n")
        print(message)

    def main(self):
        if debug:
            self.debug()
        obj = zlib.decompressobj(16 + zlib.MAX_WBITS)
        filename = os.environ['REQUEST_URI'].split('/')[-1].split('?')[0]
        offset = int(os.environ['HTTP_RANGE'].split('-')[0].strip('bytes='))
        collectionId = cgi.FieldStorage().getvalue('collectionId')
        if (collectionId is not None) and (collectionId in collection_dict):
            filedir = collection_dict[collectionId]['directory']
            ##print >> sys.stderr, 'Directory name is ' + filedir
        else:
            filedir = None
        ## TODO check that range header exists and is specified in bytes. Otherwise return a 416.
        in_body = False
        try:
            filepath = self.resolveFile(filename, filedir)
            print >> sys.stderr, "File found \''" + filepath + "\''"
            with open(filepath) as fin:
                fin.seek(offset) ## TODO check try/except that this is not larger than the file
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
                        self.onError("416 Requested Range Not Satisfiable", "Invalid offset: " + filename + ":" + str(offset))
        except IOError as e:
            self.onError("404 Not Found", "Could not find file " + filename)
            raise e

    def debug(self):
        cgitb.enable()
        cgi.test()


class PrototypeRecordService(AbstractRecordService):
    def resolveFile(self, filename, filedir):
            return '/data/' + filename

class LocalDBService(AbstractRecordService):
    def resolveFile(self, filename, filedir):
        finder = parser.get('LocalDBService', 'finder')
        if filedir is not None:
           cmds = [finder, filename, filedir]
        else:
           cmds = [finder, filename]
        print >> sys.stderr, 'Executing ' + str(cmds)
        return subprocess.check_output(cmds).strip(' \n\t')

if __name__ == "__main__":
    parser = SafeConfigParser()
    parser.read('warcrecordservice.conf')
    debug = parser.getboolean('wrs', 'debug')
    service = parser.get('wrs', 'service_class')
    collection_dict = {sect: dict(parser.items(sect)) for sect in parser.sections()}
    ##print >> sys.stderr, collection_dict
    serviceClass_ = globals()[service]
    serviceClass_().main()


