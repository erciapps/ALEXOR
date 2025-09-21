FROM eclipse-temurin:17-jdk

ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

WORKDIR /tmp

# Herramientas necesarias
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl netcat-openbsd ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Instalar Tomcat 9.0.89
RUN curl -fsSL https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz -o tomcat.tar.gz \
 && mkdir -p /opt \
 && tar xzf tomcat.tar.gz -C /opt \
 && mv /opt/apache-tomcat-9.0.89 $CATALINA_HOME \
 && rm -f tomcat.tar.gz

# Limpiar apps por defecto
RUN rm -rf $CATALINA_HOME/webapps/*

# Descargar WAR de Axelor
RUN curl -fsSL https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war \
    -o $CATALINA_HOME/webapps/ROOT.war

# Preparar carpeta "exploded" para inyectar application.properties en el classpath
RUN mkdir -p $CATALINA_HOME/webapps/ROOT/WEB-INF/classes

# Copiar configuración (quedará en el classpath del WAR)
COPY application.properties $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/application.properties

# Script: esperar a PostgreSQL antes de arrancar Tomcat
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
RUN chmod +x /usr/local/bin/wait-for-db.sh

EXPOSE 8080
WORKDIR $CATALINA_HOME

CMD [ "bash", "-lc", "wait-for-db.sh && catalina.sh run" ]

