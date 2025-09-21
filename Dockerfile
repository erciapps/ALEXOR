FROM eclipse-temurin:17-jdk

ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

WORKDIR /tmp

# Herramientas necesarias
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl wget netcat-openbsd \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Instalar Tomcat 9.0.89
RUN curl -fsSL https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz -o tomcat.tar.gz \
 && mkdir -p /opt \
 && tar xzf tomcat.tar.gz -C /opt \
 && mv /opt/apache-tomcat-9.0.89 $CATALINA_HOME \
 && rm -f tomcat.tar.gz

# Limpiar apps por defecto
RUN rm -rf $CATALINA_HOME/webapps/*

# ======== DESCARGA ROBUSTA DEL WAR ========
# OJO: si añades un archivo llamado "axelor.war" en la raíz del repo,
# se usará directamente y NO intentará descargar nada.
ARG AOS_URL="https://github.com/axelor/axelor-open-suite/releases/download/v8.4.6/axelor-erp-v8.4.6.war"

# Copia opcional del WAR desde el contexto (si existe)
# (si NO existe, no falla el build; se maneja en el siguiente RUN)
COPY --chown=root:root axelor.war /tmp/axelor.war 2>/dev/null || true

# Si no hay /tmp/axelor.war, intenta descargar con wget/curl (con reintentos).
RUN set -e; \
    if [ ! -s /tmp/axelor.war ]; then \
      echo "No se encontró axelor.war en el contexto. Intentando descargar con wget..."; \
      wget -O /tmp/axelor.war --https-only --no-verbose --tries=5 --timeout=30 "$AOS_URL" \
      || (echo "wget falló; probando curl con reintentos..." \
          && curl -fsSL --location --retry 5 --retry-all-errors --connect-timeout 15 -o /tmp/axelor.war "$AOS_URL") \
      || (echo "curl estricto falló; último intento (inseguro -k)..." \
          && curl -k -L --retry 3 -o /tmp/axelor.war "$AOS_URL"); \
    fi; \
    if [ ! -s /tmp/axelor.war ]; then echo "❌ No se pudo obtener el WAR"; exit 35; fi; \
    mv /tmp/axelor.war $CATALINA_HOME/webapps/ROOT.war

# Preparar classpath para application.properties
RUN mkdir -p $CATALINA_HOME/webapps/ROOT/WEB-INF/classes

# Tu application.properties
COPY application.properties $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/application.properties

# Script wait-for-db (igual que antes)
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
RUN chmod +x /usr/local/bin/wait-for-db.sh

EXPOSE 8080
WORKDIR $CATALINA_HOME
CMD [ "bash", "-lc", "wait-for-db.sh && catalina.sh run" ]


