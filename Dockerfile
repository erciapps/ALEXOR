FROM eclipse-temurin:17-jdk

ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

WORKDIR /tmp

RUN apt-get update && apt-get install -y curl netcat-openbsd procps \
    && rm -rf /var/lib/apt/lists/*

# Instalar Tomcat
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz \
    && mkdir -p /opt \
    && tar xzf apache-tomcat-9.0.89.tar.gz -C /opt \
    && mv /opt/apache-tomcat-9.0.89 $CATALINA_HOME \
    && rm -rf /tmp/*

RUN rm -rf $CATALINA_HOME/webapps/*

# Descargar WAR de Axelor
RUN curl -L https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war \
    -o $CATALINA_HOME/webapps/ROOT.war

# Copiar configuración
COPY application.properties $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/application.properties

# Copiar script de arranque
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["docker-entrypoint.sh"]


