# docker-geoserver 

## Todo


## Building
```
docker build -t sogis/geoserver:2.23.2 .
```

The image is built automatically by Github Action and is available from https://hub.docker.com/r/sogis/geoserver.


## Usage
```
docker run --rm --name sogis-geoserver -p 8080:8080 -v /Users/stefan/tmp/data_dir:/usr/local/geoserver/data sogis/geoserver:2.23.2
```

Set `CATALINA_OPTS` env var for tuning JVM.

## Plugins
The following plugins are added:

- ~~monitor~~
- control-flow
- pyramid
- excel output

## Links
- https://tomcat.apache.org/tomcat-9.0-doc/jndi-resources-howto.html
- https://stackoverflow.com/questions/44761831/tomcat-8-context-xml-use-environment-variable-in-datasource
- https://stackoverflow.com/questions/60604514/inject-environment-variables-in-tomcat-catalina-properties-kubernetes
- https://reachmnadeem.wordpress.com/2019/07/03/tomcat-context-file-and-environment-variables/