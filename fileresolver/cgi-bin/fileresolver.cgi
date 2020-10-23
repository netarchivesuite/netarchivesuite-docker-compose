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

    def main(self):
        if debug:
            self.debug()
        try:
            filename = os.environ['REQUEST_URI'].split('/')[-1].split('?')[0]
            filenameu = urllib.unquote(filename).strip()
            data = self.resolveFile(filenameu)
            print("Status: 200")
            print("Content-type: text/plain\r\n")
            print(data)
        except Exception as e:
            print("Status: 200")
            print("Content-type: text/plain\r\n")
            print("\r\n")
            print(e)
    def debug(self):
        cgitb.enable()
        cgi.test()


class PrototypeFileResolver(AbstractFileResolver):
    def resolveFile(self, filename):
        cmds = [finder, filename]
        pipes = subprocess.Popen(cmds , stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        std_out, std_err = pipes.communicate()
        if pipes.returncode != 0:
            err_msg = "%s. Code: %s" % (std_err.strip(), pipes.returncode)
            return err_msg
        else:
            return std_out
        ##try:
        ##    return subprocess.check_output([finder, filename],stderr=subprocess.PIPE,shell=True).strip()
        ##except subprocess.CalledProcessError as e:
        ##    print(e.returncode, e.output)


class FailingFileResolver(AbstractFileResolver):
    def resolveFile(self, filename):
        raise NameError("Failed by design!")


if __name__ == "__main__":
    parser = SafeConfigParser()
    parser.read('fileresolver.conf')
    finder = parser.get('fileresolver', 'finder')
    debug = parser.getboolean('fileresolver', 'debug')
    service = parser.get('fileresolver', 'service')
    serviceClass_ = globals()[service]
    serviceClass_().main()


