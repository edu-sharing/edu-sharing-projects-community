FROM ${docker.from.tomcat}

########################################################################################################################

USER root

RUN set -eux \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        curl \
        exiftool \
	    ffmpeg \
	    ghostscript \
	    gsfonts \
	    imagemagick \
	    jq \
	    nano \
        postgresql-client \
	    redis-tools \
        ruby-hocon \
        unzip \
        wait-for-it \
        wget \
        xmlstarlet \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN set -eux \
    && echo "deb http://deb.debian.org/debian sid main" >> /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        openjdk-8-dbg \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN set -eux \
    && rm -rf /opt/bitnami/java \
    && ln -s /usr/lib/jvm/java-8-openjdk-amd64/jre /opt/bitnami/java

########################################################################################################################

ENV ALF_HOME /opt/alfresco
ENV PATH $ALF_HOME/bin:$PATH

WORKDIR $ALF_HOME

RUN set -eux \
    && ln -sf /opt/bitnami/tomcat tomcat

RUN set -eux \
    && adduser --uid=1000 --home=$ALF_HOME --disabled-password --gecos "" --shell=/bin/bash worker \
    && mkdir -p bin \
    && mkdir -p alf_data \
    && mkdir -p tomcat/logs \
    && touch tomcat/logs/catalina.out \
    && mkdir -p tomcat/shared/classes/alfresco \
    && mkdir -p tomcat/shared/classes/config/defaults \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-cluster \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-elastic \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-mongo \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-remote \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-transform \
    && mkdir -p tomcat/shared/classes/config/cluster/applications \
    && mkdir -p tomcat/shared/classes/config/node \
    && mkdir -p tomcat/shared/lib \
    && rm -f tomcat/lib/postgresql-*

COPY --chown=worker:worker artifacts/jmx_prometheus_javaagent-${io.prometheus.jmx:jmx_prometheus_javaagent:jar.version}.jar tomcat/agent/jmx_prometheus_javaagent.jar
COPY --chown=worker:worker assets/agent/jmx-exporter-config.yaml tomcat/agent/

COPY --chown=worker:worker artifacts/postgresql-${org.postgresql:postgresql:jar.version}.jar tomcat/lib/
COPY --chown=worker:worker artifacts/redisson-all-${org.redisson:redisson-all:jar.version}.jar tomcat/lib/
COPY --chown=worker:worker artifacts/redisson-tomcat-8-${org.redisson:redisson-tomcat-8:jar.version}.jar tomcat/lib/

COPY --chown=worker:worker assets/tomcat/logging.properties tomcat/conf/logging.properties

RUN set -eux \
    && sed -i -r \
        's|^[#]*\s*shared\.loader=.*|shared.loader=${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar|' \
        tomcat/conf/catalina.properties \
    && xmlstarlet ed -L \
        -s '/Context' -t elem -n "Resources" -v "" \
        --var resources '$prev' \
        -i '$resources' -t attr -n "cacheMaxSize" -v "20480" \
        tomcat/conf/context.xml

COPY --chown=worker:worker artifacts/alfresco-platform-community-distributionzip-${org.alfresco:alfresco-platform-community-distributionzip:zip.version}.zip \
    /tmp/alfresco-platform-community-distributionzip.zip

RUN set -eux \
    && mkdir -p /tmp/install \
	&& unzip /tmp/alfresco-platform-community-distributionzip.zip -d /tmp/install \
	&& rm -f /tmp/alfresco-platform-community-distributionzip.zip \
	&& mv /tmp/install/alfresco-platform-community-distributionzip* /tmp/install/alfresco-platform \
    && mv /tmp/install/alfresco-platform/alf_data . \
    && mv /tmp/install/alfresco-platform/licenses . \
    && mv /tmp/install/alfresco-platform/README.txt . \
    && cp -rf /tmp/install/alfresco-platform/bin/* bin \
    && cp -rf /tmp/install/alfresco-platform/web-server/conf/* tomcat/conf \
    && cp -rf /tmp/install/alfresco-platform/web-server/shared/* tomcat/shared \
    && cp -rf /tmp/install/alfresco-platform/web-server/webapps/* tomcat/webapps \
    && rm -rf /tmp/install/alfresco-platform \
    && mkdir -p tomcat/webapps/alfresco \
    && unzip tomcat/webapps/alfresco.war -d tomcat/webapps/alfresco \
      -x "WEB-INF/classes/logging.properties" \
      -x "WEB-INF/classes/log4j.properties" \
      -x "WEB-INF/lib/commons-lang3-*" \
      -x "WEB-INF/lib/hazelcast-*" \
      -x "WEB-INF/lib/jackson-*" \
      -x "WEB-INF/lib/log4j-*" \
      -x "WEB-INF/lib/slf4j-*" \
      -x "WEB-INF/lib/jsr305-*" \
      -x "WEB-INF/lib/asm-*" \
      -x "WEB-INF/lib/antlr-2.*" \
    && rm -f tomcat/webapps/alfresco.war \
    && mv alf_data/keystore .

RUN set -eux \
    && xmlstarlet ed -L -d '/Context/Loader' tomcat/conf/Catalina/localhost/alfresco.xml

COPY --chown=worker:worker artifacts/alfresco-content-services-share-distribution-${org.alfresco:alfresco-content-services-share-distribution:zip.version}.zip \
    /tmp/alfresco-content-services-share-distribution.zip

RUN set -eux \
    && mkdir -p /tmp/install \
	&& unzip /tmp/alfresco-content-services-share-distribution.zip -d /tmp/install \
	&& rm -f /tmp/alfresco-content-services-share-distribution.zip \
	&& mv /tmp/install/alfresco-content-services-share-distribution* /tmp/install/alfresco-share \
	&& java -jar bin/alfresco-mmt.jar install /tmp/install/alfresco-share/amps/alfresco-share-services.amp \
        tomcat/webapps/alfresco -nobackup -force \
    && mv /tmp/install/alfresco-share/web-extension* tomcat/shared/classes/alfresco/web-extension \
    && cp -rf /tmp/install/alfresco-share/web-server/conf/* tomcat/conf \
    && cp -rf /tmp/install/alfresco-share/web-server/webapps/* tomcat/webapps \
    && rm -rf /tmp/install/alfresco-share \
    && mkdir -p tomcat/webapps/share \
    && unzip tomcat/webapps/share.war -d tomcat/webapps/share \
    && rm -f tomcat/webapps/share.war

RUN set -eux \
    && xmlstarlet ed -L -d '/Context/Loader' tomcat/conf/Catalina/localhost/share.xml

COPY --chown=worker:worker assets/share/log4j.properties tomcat/webapps/share/WEB-INF/classes/log4j.properties

COPY --chown=worker:worker artifacts/alfresco-pdf-renderer-${org.alfresco:alfresco-pdf-renderer:tgz:linux.version}-linux.tgz /tmp/alfresco-pdf-renderer.tgz

RUN set -eux \
	&& mkdir -p /tmp/install/alfresco-pdf-renderer \
    && tar -xvzf /tmp/alfresco-pdf-renderer.tgz -C /tmp/install/alfresco-pdf-renderer \
    && rm -f /tmp/alfresco-pdf-renderer.tgz \
    && mkdir -p common \
    && mv /tmp/install/alfresco-pdf-renderer common/alfresco-pdf-renderer

COPY --chown=worker:worker artifacts/edu_sharing-community-repository-backend-tomcat-${org.edu_sharing:edu_sharing-community-repository-backend-tomcat:jar.version}.jar tomcat/lib/

COPY --chown=worker:worker webapp/*.war tomcat/webapps/edu-sharing.war

RUN set -eux \
    && mkdir -p tomcat/webapps/edu-sharing \
	&& unzip tomcat/webapps/edu-sharing.war -d tomcat/webapps/edu-sharing \
	&& rm -f tomcat/webapps/edu-sharing.war \
	&& cp tomcat/webapps/edu-sharing/META-INF/context.xml tomcat/conf/Catalina/localhost/edu-sharing.xml

COPY --chown=worker:worker amps amps/

COPY --chown=worker:worker config tomcat/shared/assets/

RUN set -eux \
    && chown -RL worker:worker alf_data \
    && chown -RL worker:worker tomcat/conf \
    && chown -RL worker:worker tomcat/shared \
    && chown -RL worker:worker tomcat/webapps \
    && chown -RL worker:worker tomcat/work \
    && chown -RL worker:worker tomcat/temp

########################################################################################################################

COPY --chown=worker:worker assets/entrypoint.sh assets/reinstall.sh assets/libcheck.sh bin/

COPY --chown=worker:worker assets/plugins bin/plugins/

RUN set -eux \
	&& find bin -type f -name '*.sh' -exec chmod +x {} \;

########################################################################################################################

RUN set -eux \
    && mkdir profiler \
    && wget -qO- https://github.com/Granulate/async-profiler/releases/download/v2.0g1/async-profiler-2.0-linux-x64.tar.gz | tar xvz -C profiler \
    && chown -RL worker:worker profiler

COPY --chown=worker:worker assets/profiler profiler/

########################################################################################################################

USER worker

STOPSIGNAL SIGWINCH

EXPOSE 8009 8080 8081

ENTRYPOINT ["entrypoint.sh"]
CMD ["catalina.sh", "run"]

VOLUME [ "/opt/alfresco/alf_data", "/opt/bitnami/tomcat/shared/classes/config/cluster", "/opt/bitnami/tomcat/shared/classes/config/node" ]

########################################################################################################################


LABEL git.branch=${git.branch}
LABEL git.closest.tag.name=${git.closest.tag.fixed}
LABEL git.commit.id=${git.commit.id}
LABEL git.dirty=${git.dirty}
LABEL mvn.project.artifactId=${project.artifactId}
LABEL mvn.project.groupId=${project.groupId}
LABEL mvn.project.version=${project.version}
