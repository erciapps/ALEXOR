FROM eclipse-temurin:17-jdk

WORKDIR /opt/axelor

# Descargar WAR de Axelor
ADD https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war app.war

# Instalar Jetty
RUN apt-get update && apt-get install -y jetty9 && rm -rf /var/lib/apt/lists/*

EXPOSE 8084

CMD ["java", "-jar", "/usr/share/jetty9/start.jar", "--module=deploy", "jetty.base=/opt/axelor", "jetty.deploy.monitoredDir=/opt/axelor"]
