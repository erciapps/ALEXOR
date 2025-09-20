FROM eclipse-temurin:17-jdk

# Variables de entorno
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# Instalamos Tomcat
WORKDIR /tmp
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz \
    && mkdir -p /opt \
    && tar xzf apache-tomcat-9.0.89.tar.gz -C /opt \
    && mv /opt/apache-tomcat-9.0.89 $CATALINA_HOME \
    && rm -rf /tmp/*

# Limpiamos apps por defecto
RUN rm -rf $CATALINA_HOME/webapps/*

# Descargamos WAR de Axelor y lo ponemos como ROOT
RUN curl -L https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war \
    -o $CATALINA_HOME/webapps/ROOT.war

# Copiamos configuración personalizada (montada desde docker-compose)
# Axelor lee application.properties desde $CATALINA_HOME/conf
COPY application.properties $CATALINA_HOME/conf/application.properties

EXPOSE 8080
CMD ["catalina.sh", "run"]

