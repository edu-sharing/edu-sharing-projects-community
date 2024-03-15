FROM ${docker.from}community/edu_sharing-community-repository-deploy-docker-build-service:${org.edu_sharing:edu_sharing-community-repository-deploy-docker-build-service:jar:sources.version}

########################################################################################################################

USER root

RUN set -eux \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-antivirus \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-cluster \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-elastic \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-mongo \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-remote \
    && mkdir -p tomcat/shared/classes/config/plugins/plugin-transform \
    && chown -RL worker:worker tomcat/shared/classes/config/plugins

COPY --chown=worker:worker webapp/*.war tomcat/webapps/edu-sharing.war

RUN set -eux \
    && rm -rf tomcat/webapps/edu-sharing \
    && mkdir -p tomcat/webapps/edu-sharing \
	&& unzip tomcat/webapps/edu-sharing.war -d tomcat/webapps/edu-sharing \
	&& rm -f tomcat/webapps/edu-sharing.war \
	&& cp -f tomcat/webapps/edu-sharing/META-INF/context.xml tomcat/conf/Catalina/localhost/edu-sharing.xml

COPY --chown=worker:worker amps amps/
COPY --chown=worker:worker shared tomcat/shared/

RUN set -eux \
    && chown -RL worker:worker alf_data \
    && chown -RL worker:worker tomcat/conf \
    && chown -RL worker:worker tomcat/shared \
    && chown -RL worker:worker tomcat/webapps \
    && chown -RL worker:worker tomcat/work \
    && chown -RL worker:worker tomcat/temp

########################################################################################################################

COPY --chown=worker:worker assets/plugins bin/plugins/

RUN set -eux \
	&& find bin -type f -name '*.sh' -exec chmod +x {} \;

########################################################################################################################

USER worker

########################################################################################################################

LABEL git.branch=${git.branch} \
git.closest.tag.name=${git.closest.tag.fixed} \
git.commit.id=${git.commit.id} \
git.dirty=${git.dirty} \
mvn.project.artifactId=${project.artifactId} \
mvn.project.groupId=${project.groupId} \
mvn.project.version=${project.version}
