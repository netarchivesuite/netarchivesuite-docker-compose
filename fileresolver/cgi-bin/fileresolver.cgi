#!/usr/bin/python2.7
import zlib, cgitb, cgi, os, subprocess, urllib
from ConfigParser import SafeConfigParser


class AbstractFileResolver:

    def resolveFile(self, filename):
        raise Exception("resolveFile method not implemented")

    def onError(self, returnCode, message, e):
        print ("Status: " + returnCode)
        print ("Content-Type: text/html\r\n")
        print (message)
        print ("\r\n")
        print (e)

    def main(self, collection_dict):
        if debug:
            self.debug()
        try:
            pattern = os.environ['REQUEST_URI'].split('/')[-1].split('?')[0]
            pattern_decoded = urllib.unquote(pattern).strip()
            collectionId = cgi.FieldStorage().getValue('collectionId')
            filedir = None
            if collectionId is not None:
                filedir = collection_dict[collectionId][directory]
            data = self.resolveFile(pattern_decoded, filedir)
            print("Status: 200")
            print("Content-type: text/plain\r\n")
            print(data)
        except Exception as e:
            onError(500, "Error matching " + pattern, e)
    def debug(self):
        cgitb.enable()
        cgi.test()


class PrototypeFileResolver(AbstractFileResolver):
    def resolveFile(self, filename, filedir):
        cmds = [finder, filename, filedir]
        try:
            return subprocess.check_output(cmds)
        except Exception as e:
            ## Expected on zero matches
            return ""




class FailingFileResolver(AbstractFileResolver):
    def resolveFile(self, filename, filedir):
        raise NameError("Failed by design!")


if __name__ == "__main__":
    parser = SafeConfigParser()
    parser.read('fileresolver.conf')
    finder = parser.get('fileresolver', 'finder')
    debug = parser.getboolean('fileresolver', 'debug')
    service = parser.get('fileresolver', 'service')
    collection_dict = {sect: dict(parser.items(sect)) for sect in parser.sections()}
    collection_dict.pop('fileresolver', None)
    //print(collection_dict['netarkivet']['directory'])
    serviceClass_ = globals()[service]
    serviceClass_().main(collection_dict)
