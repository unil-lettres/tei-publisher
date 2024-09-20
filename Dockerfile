ARG EXISTDB_VERSION=6.2.0-debug-j8

FROM debian:latest AS sources

ARG ROUTER_VERSION=1.8.0
ARG PUBLISHER_LIB_VERSION=4.0.0
ARG TEMPLATING_VERSION=1.1.0

USER root

RUN apt-get update && apt-get install -y curl

RUN mkdir -p /tmp/packages

# Download tei-publisher dependencies.
RUN curl -L -o /tmp/packages/roaster-${ROUTER_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/roaster-${ROUTER_VERSION}.xar
RUN curl -L -o /tmp/packages/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o /tmp/packages/templating-${TEMPLATING_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar

FROM duncdrum/existdb:${EXISTDB_VERSION} AS existdb

WORKDIR /exist

COPY --from=sources /tmp/packages/*.xar /exist/autodeploy/
COPY --from=sources /tmp/*.xar /exist/autodeploy/

ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443

# Adjust CONTEXT_PATH if the app is served from a subfolder.
ARG CONTEXT_PATH=auto

ARG NER_ENDPOINT=http://localhost:8001
ARG PROXY_CACHING=false

ENV JAVA_TOOL_OPTIONS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -Dorg.exist.db-connection.cacheSize=${CACHE_MEM:-256}M \
  -Dorg.exist.db-connection.pool.max=${MAX_BROKER:-20} \
  -Dlog4j.configurationFile=/exist/etc/log4j2.xml \
  -Dexist.home=/exist \
  -Dexist.configurationFile=/exist/etc/conf.xml \
  -Djetty.home=/exist \
  -Dexist.jetty.config=/exist/etc/jetty/standard.enabled-jetty-configs \
  -Dteipublisher.ner-endpoint=${NER_ENDPOINT} \
  -Dteipublisher.context-path=${CONTEXT_PATH} \
  -Dteipublisher.proxy-caching=${PROXY_CACHING} \
  -XX:+UseG1GC \
  -XX:+UseStringDeduplication \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \
  -XX:+ExitOnOutOfMemoryError

# pre-populate the database by launching it once
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l" ]

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN [ "chmod", "+x", "/usr/local/bin/entrypoint.sh" ]
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["java", "org.exist.start.Main", "jetty"]
