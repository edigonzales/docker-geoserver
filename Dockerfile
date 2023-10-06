FROM tomcat:9-jre11
#FROM tomcat:9-jre11-temurin

LABEL maintainer="Stefan Ziegler stefan.ziegler.de@gmail.com"

ENV CATALINA_HOME=/usr/local/tomcat
ARG GEOSERVER_VERSION=2.23.2
ENV GEOSERVER_DATA_DIR /usr/local/geoserver/data
ENV GEOSERVER_INSTALL_DIR /usr/local/geoserver

RUN set -x \
    && apt-get update \
    && apt-get install unzip

# Uncomment to use APT cache (requires apt-cacher-ng on host)
#RUN echo "Acquire::http { Proxy \"http://`/sbin/ip route|awk '/default/ { print $3 }'`:3142\"; };" > /etc/apt/apt.conf.d/71-apt-cacher-ng

# Microsoft fonts
#RUN echo "deb http://httpredir.debian.org/debian stretch contrib" >> /etc/apt/sources.list
#RUN set -x \
#	&& apt-get update \
#	&& apt-get install -yq ttf-mscorefonts-installer \
#	&& rm -rf /var/lib/apt/lists/*

#RUN apt-get update && apt-get install -y wget unzip

#SOGIS fonts
ADD fonts/* /usr/share/fonts/truetype/
RUN fc-cache -f && fc-list | sort

# GeoServer
ADD conf/geoserver.xml /usr/local/tomcat/conf/Catalina/localhost/geoserver.xml
RUN mkdir ${GEOSERVER_INSTALL_DIR} \
    && cd ${GEOSERVER_INSTALL_DIR} \
    && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip \
    && unzip geoserver-${GEOSERVER_VERSION}-war.zip \
    && unzip geoserver.war \
    && rm -rf geoserver-${GEOSERVER_VERSION}-war.zip geoserver.war target *.txt

RUN mv ${GEOSERVER_INSTALL_DIR}/WEB-INF/lib/marlin-*.jar $CATALINA_HOME/lib/marlin.jar

# Replace default data directory
#RUN mkdir -p /tmp/gs_tmp
#ADD data_dir /tmp/gs_tmp
#RUN mv /tmp/gs_tmp/* ${GEOSERVER_DATA_DIR}

# GeoServer modules    
RUN cd ${GEOSERVER_INSTALL_DIR}/WEB-INF/lib \
    # && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip \
    # && unzip -o geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip \
    # && rm -rf geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip  \
    && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-control-flow-plugin.zip \
    && unzip -o geoserver-${GEOSERVER_VERSION}-control-flow-plugin.zip \
    && rm -rf geoserver-${GEOSERVER_VERSION}-control-flow-plugin.zip \
    && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-pyramid-plugin.zip \
    && unzip -o geoserver-${GEOSERVER_VERSION}-pyramid-plugin.zip \
    && rm -rf geoserver-${GEOSERVER_VERSION}-pyramid-plugin.zip 

# Enable CORS
RUN sed -i '\:</web-app>:i\
<filter>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
    <init-param>\n\
        <param-name>cors.allowed.origins</param-name>\n\
        <param-value>*</param-value>\n\
    </init-param>\n\
    <init-param>\n\
        <param-name>cors.allowed.methods</param-name>\n\
        <param-value>GET,POST,HEAD,OPTIONS,PUT</param-value>\n\
    </init-param>\n\
</filter>\n\
<filter-mapping>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <url-pattern>/*</url-pattern>\n\
</filter-mapping>' ${GEOSERVER_INSTALL_DIR}/WEB-INF/web.xml

# Jndi 
RUN cp ${GEOSERVER_INSTALL_DIR}/WEB-INF/lib/postgresql-42.6.0.jar $CATALINA_HOME/lib/postgresql-42.6.0.jar
RUN rm ${GEOSERVER_INSTALL_DIR}/WEB-INF/lib/postgresql-42.6.0.jar 
COPY context.xml $CATALINA_HOME/conf/context.xml

# Eher zu Geoserver?
COPY jars/geoserver-layerinfo-*.jar $CATALINA_HOME/lib/

# Tomcat environment
ENV CATALINA_OPTS "-server -Djava.awt.headless=true \
    -Dfile.encoding=UTF-8 \
    -Djavax.servlet.request.encoding=UTF-8 \
    -Djavax.servlet.response.encoding=UTF-8 \
    -D-XX:SoftRefLRUPolicyMSPerMB=36000 \
	-Xms2048m -Xmx2048m \
    -Xbootclasspath/a:$CATALINA_HOME/lib/marlin.jar \
    -Dsun.java2d.renderer=sun.java2d.marlin.DMarlinRenderingEngine \
    -Dorg.geotools.coverage.jaiext.enabled=true \
    -DGEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR} \
    -Dorg.geoserver.htmlTemplates.staticMemberAccess=* \
    -Dorg.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.EnvironmentPropertySource"

ADD start.sh /usr/local/bin/start.sh
CMD start.sh

EXPOSE 8080