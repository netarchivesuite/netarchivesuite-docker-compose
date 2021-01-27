## Prototype python-cgi script for accessing warc-records.
### Starting the service

    docker-compose -f docker-compose-wrs.yml up


### Using curl against the service
In order to fetch a warc record through the service run the following command:

```console
curl --cert-type P12 --cert test-client.p12:test -r "0-" https://localhost:10443/cgi-bin/warcrecordservice.cgi/test.warc.gz --insecure
```

Here in the test-environment, the `--insecure` flag is necessary, because the Certificate Authority that was used 
to issue a certificate for the service was generated using a self-signed certificate. 
The legitimacy of such a certificate can of course not be verified and thus curl fails without the flag.

### Access the service through the browser
In case you just want to see that the service is up and running through the browser, 
you can simply go to your browser settings under '*Manage certificates*' and import the pkcs12-file, e.g. test-client.p12.
You should then be able to access the Apache default site at https://localhost:10443.

### Certificate passwords
Any passwords associated with the provided test certificates are just "**test**".

## Generating new client certificates
To generate the test-client certificate, the following openssl commands have been run one-by-one:
```console
openssl genrsa -out test-client.key 2048
openssl req -new -key test-client.key -sha256 -out test-client.csr
openssl x509 -req -days 365 -sha256 -in test-client.csr -CA ca.crt -CAkey ca.key -set_serial 2 -out test-client.crt
openssl pkcs12 -export -inkey test-client.key -in test-client.crt -out test-client.p12
openssl pkcs12 -in test-client.p12 -out test-client.pem -nodes (if you want PEM format)
```
In order to create a new certificate just follow the same steps and change any `test-client.*` part to the path you wish for.

When generating the csr-file you are prompted to fill in some details. You can just leave all fields blank (by entering '.'), 
but you probably want to enter something for `Common Name`.