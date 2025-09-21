FROM eclipse-temurin:17-jdk

ENV CATALINA_HOME=/opt/tomcat
ENV PATH=${CATALINA_HOME}/bin:$PATH

# Paquetes
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl wget netcat-openbsd procps \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Tomcat 9.0.89
WORKDIR /tmp
RUN curl -fsSL https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz -o tomcat.tar.gz \
 && mkdir -p /opt \
 && tar xzf tomcat.tar.gz -C /opt \
 && mv /opt/apache-tomcat-9.0.89 ${CATALINA_HOME} \
 && rm -f tomcat.tar.gz \
 && rm -rf ${CATALINA_HOME}/webapps/*

# ↓↓↓ Descarga robusta del WAR (sin COPY opcional) ↓↓↓
ARG AOS_URL="https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war"
RUN (wget -O /tmp/axelor.war --https-only --no-verbose --tries=5 --timeout=30 "$AOS_URL" \
  || curl -fsSL --location --retry 5 --retry-all-errors --connect-timeout 20 -o /tmp/axelor.war "$AOS_URL" \
  || (echo "⚠️ curl estricto falló; probando con -k" && curl -k -L --retry 3 -o /tmp/axelor.war "$AOS_URL")) \
 && test -s /tmp/axelor.war \
 && mv /tmp/axelor.war ${CATALINA_HOME}/webapps/ROOT.war

# application.properties dentro del classpath del WAR desplegado
RUN mkdir -p ${CATALINA_HOME}/webapps/ROOT/WEB-INF/classes
COPY application.properties ${CATALINA_HOME}/webapps/ROOT/WEB-INF/classes/application.properties

# Espera a DB y arranca
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
RUN chmod +x /usr/local/bin/wait-for-db.sh

WORKDIR ${CATALINA_HOME}
EXPOSE 8080
CMD [ "bash", "-lc", "wait-for-db.sh && catalina.sh run" ]


