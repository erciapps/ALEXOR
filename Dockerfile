FROM eclipse-temurin:17-jdk

ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

WORKDIR /tmp
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz \
    && mkdir -p /opt \
    && tar xzf apache-tomcat-9.0.89.tar.gz -C /opt \
    && mv /opt/apache-tomcat-9.0.89 $CATALINA_HOME \
    && rm -rf /tmp/*

# Limpiar apps por defecto
RUN rm -rf $CATALINA_HOME/webapps/*

# Descargar el WAR
RUN curl -L https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war \
    -o $CATALINA_HOME/webapps/ROOT.war

# Desplegar WAR expandido
RUN mkdir -p $CATALINA_HOME/webapps/ROOT \
    && cd $CATALINA_HOME/webapps/ROOT \
    && jar -xf ../ROOT.war \
    && rm ../ROOT.war

# Copiar fichero de configuración dentro del WAR expandido
COPY application.properties $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/application.properties

EXPOSE 8080
CMD ["catalina.sh", "run"]

