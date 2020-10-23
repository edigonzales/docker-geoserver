# docker-geoserver 
Building:
```
docker build -t sogis/geoserver:2.18.0 .
```

The image is built automatically by Github Action and is available from https://hub.docker.com/r/sogis/geoserver.

```
docker run --rm --name sogis-geoserver -p 8080:8080 -v /Users/stefan/tmp/data_dir:/var/local/geoserver sogis/geoserver:2.18.0
```