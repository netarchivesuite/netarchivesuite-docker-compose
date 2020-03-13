WebDAV docker container
=========================
Docker image with WebDAV configured using https://httpd.apache.org/ . Exports /site/dav volume, so you can use that to provide remotely accessible directory for other container.
   
Quickstart:
-----------
	 docker run -it -p 80:80 blekinge/apache_webdav

Customizing:
------------
This will run webdav server without authentification so not very secure. 

This image does not work well with user namespaces, a new feature in docker. The fundamental problem is that the apache user MUST NOT BE ROOT. But with user namespaces you can make a guest user root and have him map to a non-root host user. 
 So, start it with the param

    --userns=host

If you specify a local volume for `/site/dav`, you can specify the user and group of the apache server. This is not nessesary, however, as the apache server will, per default, run as the user that owns `/site/dav`

    -v $PWD/tmp:/site/dav 

If you want to override this, specify the environment variables `uid` and `gid`.

    -e uid=$(id -u) -e gid=$(id -g)

The `dockerEntry.sh` script will create a user/group (`docker/docker`) in the container, as it starts up. The apache server will start as root, in order to bind port 80, but will then drop down
to run as `docker`. 

This gives this combined start line
    
    docker run -it -v $PWD/tmp:/site/dav -p 80:80 --userns=host -e uid=$(id -u) -e gid=$(id -g) apache_webdav

Building your own:
------------------

In the dir with Dockerfile:

	docker build -t apache_webdav .

