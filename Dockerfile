FROM tomcat:9.0-jdk17

# Descargar el WAR de Axelor directamente desde GitHub
ADD https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8084
