#!/usr/bin/python2.7
import zlib, cgitb, cgi, os


class AbstractFileResolver

    def resolveFile(self, filename):
          raise Exception("resolveFile method not implemented")

    def onError(self, returnCode, message):
        print ("Status: " + returnCode)
        print ("Content-Type: text/html\r\n")
        print(message)

    def main(self):
        ## TODO make debugging switchable in config file
        self.debug()



    def debug(self):
        cgitb.enable()
        cgi.test()


class PrototypeFileResolver(AbstractFileResolver):
    def resolveFile(self, filename):
            ## form = cgi.FieldStorage()
            ## TODO form values can be used in other implementations e.g. form["collection"].value might be part of the file path
            return '/kbhpillar/collection-netarkivet/' + filename

if __name__ == "__main__":
    ## TODO read the service name from a config-file
    service = "PrototypeFileResolver"
    serviceClass_ = globals()[service]
    serviceClass_().main()


