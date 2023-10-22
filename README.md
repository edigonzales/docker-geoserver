# docker-geoserver 

## Todo
- Fix: `16-Sep-2023 15:26:42.645 WARNING [main] java.util.ArrayList.forEach Name = pub Property maxActive is not used in DBCP2, use maxTotal instead. maxTotal default value is 8. You have set value of "50" for "maxActive" property, which is being ignored`
- Fix: `16-Sep-2023 15:26:42.646 WARNING [main] java.util.ArrayList.forEach Name = pub Property maxWait is not used in DBCP2 , use maxWaitMillis instead. maxWaitMillis default value is PT-0.001S. You have set value of "-1" for "maxWait" property, which is being ignored.` -> https://tomcat.apache.org/tomcat-9.0-doc/jndi-resources-howto.html

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

## Env Vars in Tomcat
- https://stackoverflow.com/questions/44761831/tomcat-8-context-xml-use-environment-variable-in-datasource
- https://stackoverflow.com/questions/60604514/inject-environment-variables-in-tomcat-catalina-properties-kubernetes
- https://reachmnadeem.wordpress.com/2019/07/03/tomcat-context-file-and-environment-variables/