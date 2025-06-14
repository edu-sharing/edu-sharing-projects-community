## Parameters

### Global parameters

| Name                  | Description                            | Value                              |
| --------------------- | -------------------------------------- | ---------------------------------- |
| `global.patroni.name` | Override Postgres Zalando Patroni name | `edusharing-repository-postgresql` |

### Local parameters

| Name           | Description              | Value                   |
| -------------- | ------------------------ | ----------------------- |
| `nameOverride` | Override repository name | `edusharing-repository` |

### Dependency

| Name                                                                      | Description                                            | Value                                                             |
| ------------------------------------------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------- |
| `edusharing_repository_antivirus.enabled`                                 | Enable antivirus repository                            | `${helm.edusharing_repository_antivirus.enabled}`                 |
| `edusharing_repository_antivirus.nameOverride`                            | Override antivirus repository name                     | `edusharing-repository-antivirus`                                 |
| `edusharing_repository_antivirus.service.port.api`                        | Set port for antivirus repository service api          | `1344`                                                            |
| `edusharing_repository_postgresql.enabled`                                | Enable postgresql repository                           | `true`                                                            |
| `edusharing_repository_postgresql.nameOverride`                           | Override postgresql repository name                    | `edusharing-repository-postgresql`                                |
| `edusharing_repository_postgresql.image.name`                             | Set postgresql repository image name                   | `${docker.edu_sharing.community.common.postgresql.name}`          |
| `edusharing_repository_postgresql.image.tag`                              | Set postgresql repository image tag                    | `${docker.edu_sharing.community.common.postgresql.tag}`           |
| `edusharing_repository_postgresql.service.port.api`                       | Set postgresql repository service api port             | `5432`                                                            |
| `edusharing_repository_postgresql.config.database`                        | Set postgresql repository database                     | `repository`                                                      |
| `edusharing_repository_postgresql.config.username`                        | Set postgresql repository username                     | `repository`                                                      |
| `edusharing_repository_postgresql.init.permission.image.name`             | Set postgresql repository init permission image name   | `${docker.edu_sharing.community.common.minideb.name}`             |
| `edusharing_repository_postgresql.init.permission.image.tag`              | Set postgresql repository init permission image tag    | `${docker.edu_sharing.community.common.minideb.tag}`              |
| `edusharing_repository_postgresql.job.dump.image.name`                    | Set postgresql repository job dump image name          | `${docker.edu_sharing.community.common.postgresql.name}`          |
| `edusharing_repository_postgresql.job.dump.image.tag`                     | Set postgresql repository job dump image tag           | `${docker.edu_sharing.community.common.postgresql.tag}`           |
| `edusharing_repository_postgresql.sidecar.metrics.image.name`             | Set postgresql repository sidecar metrics image name   | `${docker.edu_sharing.community.common.postgresql.exporter.name}` |
| `edusharing_repository_postgresql.sidecar.metrics.image.tag`              | Set postgresql repository sidecar metrics image tag    | `${docker.edu_sharing.community.common.postgresql.exporter.tag}`  |
| `edusharing_repository_rediscluster.enabled`                              | Enable rediscluster repository                         | `true`                                                            |
| `edusharing_repository_rediscluster.nameOverride`                         | Override repository rediscluster name                  | `edusharing-repository-rediscluster`                              |
| `edusharing_repository_rediscluster.image.name`                           | Set repository rediscluster image name                 | `${docker.edu_sharing.community.common.redis-cluster.name}`       |
| `edusharing_repository_rediscluster.image.tag`                            | Set repository rediscluster image tag                  | `${docker.edu_sharing.community.common.redis-cluster.tag}`        |
| `edusharing_repository_rediscluster.service.port.api`                     | Set port of rediscluster repository service api        | `6379`                                                            |
| `edusharing_repository_rediscluster.init.permission.image.name`           | Set rediscluster repository permission image name      | `${docker.edu_sharing.community.common.minideb.name}`             |
| `edusharing_repository_rediscluster.init.permission.image.tag`            | Set rediscluster repository permission image tag       | `${docker.edu_sharing.community.common.minideb.tag}`              |
| `edusharing_repository_rediscluster.init.sysctl.image.name`               | Set rediscluster repository sysctl image name          | `${docker.edu_sharing.community.common.minideb.name}`             |
| `edusharing_repository_rediscluster.init.sysctl.image.tag`                | Set rediscluster repository sysctl image tag           | `${docker.edu_sharing.community.common.minideb.tag}`              |
| `edusharing_repository_rediscluster.sidecar.metrics.image.name`           | Set rediscluster repository metrics sidecar image name | `${docker.edu_sharing.community.common.redis.exporter.name}`      |
| `edusharing_repository_rediscluster.sidecar.metrics.image.tag`            | Set rediscluster repository metrics sidecar image tag  | `${docker.edu_sharing.community.common.redis.exporter.tag}`       |
| `edusharing_repository_mongo.enabled`                                     | Enable mongo repository                                | `${helm.edusharing_repository_mongo.enabled}`                     |
| `edusharing_repository_mongo.nameOverride`                                | Override mongo repository name                         | `edusharing-repository-mongo`                                     |
| `edusharing_repository_mongo.image.name`                                  | Set repository rediscluster image name                 | `${docker.edu_sharing.community.common.mongodb.name}`             |
| `edusharing_repository_mongo.image.tag`                                   | Set repository rediscluster image tag                  | `${docker.edu_sharing.community.common.mongodb.tag}`              |
| `edusharing_repository_mongo.service.port.api`                            | Set mongo repository service api port                  | `27017`                                                           |
| `edusharing_repository_mongo.config.database`                             | Set mongo repository database                          | `repository`                                                      |
| `edusharing_repository_mongo.config.username`                             | Set mongo repository username                          | `repository`                                                      |
| `edusharing_repository_mongo.init.permission.image.name`                  | Set init container image name                          | `${docker.edu_sharing.community.common.minideb.name}`             |
| `edusharing_repository_mongo.init.permission.image.tag`                   | Set init container image tag                           | `${docker.edu_sharing.community.common.minideb.tag}`              |
| `edusharing_repository_mongo.job.dump.image.name`                         | Set dump job image name                                | `${docker.edu_sharing.community.common.mongodb.name}`             |
| `edusharing_repository_mongo.job.dump.image.tag`                          | Set dump job image tag                                 | `${docker.edu_sharing.community.common.mongodb.tag}`              |
| `edusharing_repository_mongo.sidecar.metrics.image.name`                  | Set metrics sidecar image name                         | `${docker.edu_sharing.community.common.mongodb.exporter.name}`    |
| `edusharing_repository_mongo.sidecar.metrics.image.tag`                   | Set metrics sidecar image tag                          | `${docker.edu_sharing.community.common.mongodb.exporter.tag}`     |
| `edusharing_repository_search_elastic_index.enabled`                      | Enable search elastic index repository                 | `${helm.edusharing_repository_search_elastic_index.enabled}`      |
| `edusharing_repository_search_elastic_index.nameOverride`                 | Override search elastic index repository name          | `edusharing-repository-search-elastic-index`                      |
| `edusharing_repository_search_elastic_index.service.port.api`             | Set search elastic index repository service api port   | `9200`                                                            |
| `edusharing_repository_search_solr.enabled`                               | Enable search solr repository                          | `true`                                                            |
| `edusharing_repository_search_solr.nameOverride`                          | Override search solr repository name                   | `edusharing-repository-search-solr`                               |
| `edusharing_repository_search_solr.service.port.api`                      | Set search solr repository service api port            | `9200`                                                            |
| `edusharing_repository_search_solr.config.repository.host`                | Set search solr repository host                        | `edusharing-repository-service`                                   |
| `edusharing_repository_search_solr.config.repository.port`                | Set search solr repository port                        | `8080`                                                            |
| `edusharing_repository_transform.enabled`                                 | Enable transform repository                            | `${helm.edusharing_repository_transform.enabled}`                 |
| `edusharing_repository_transform.nameOverride`                            | Override transform repository name                     | `edusharing-repository-transform`                                 |
| `edusharing_repository_transform.service.port.api`                        | Set port of transform repository service api           | `8080`                                                            |
| `edusharing_repository_transform_aio.enabled`                             | Enable transform_aio repository                        | `true`                                                            |
| `edusharing_repository_transform_aio.nameOverride`                        | Override transform_aio repository name                 | `edusharing-repository-transform-aio`                             |
| `edusharing_repository_transform_aio.service.port.api`                    | Set port of transform_aio repository service api       | `8090`                                                            |
| `edusharing_repository_transform_es.enabled`                              | Enable transform_es repository                         | `true`                                                            |
| `edusharing_repository_transform_es.nameOverride`                         | Override transform_es repository name                  | `edusharing-repository-transform-es`                              |
| `edusharing_repository_transform_es.service.port.api`                     | Set port for transform_aes repository service api      | `8091`                                                            |
| `edusharing_repository_service.enabled`                                   | Enable repository service                              | `true`                                                            |
| `edusharing_repository_service.nameOverride`                              | Override repository service name                       | `edusharing-repository-service`                                   |
| `edusharing_repository_service.image.repository`                          | Set repository service image repository                | `${docker.repository}`                                            |
| `edusharing_repository_service.image.name`                                | Set repository service image name                      | `${docker.prefix}-deploy-docker-build-repository-service`         |
| `edusharing_repository_service.image.tag`                                 | Set repository service image tag                       | `${docker.tag}`                                                   |
| `edusharing_repository_service.service.port.api.internal`                 | Set port for repository service internal service api   | `8080`                                                            |
| `edusharing_repository_service.config.antivirus.enabled`                  | Enable repository service antivirus                    | `${helm.edusharing_repository_antivirus.enabled}`                 |
| `edusharing_repository_service.config.antivirus.host`                     | Set host for repository service antivirus              | `edusharing-repository-antivirus`                                 |
| `edusharing_repository_service.config.antivirus.port`                     | Set port for repository service antivirus              | `1344`                                                            |
| `edusharing_repository_service.config.cache.host`                         | Set host for repository service cache                  | `edusharing-repository-rediscluster`                              |
| `edusharing_repository_service.config.cache.port`                         | Set port for repository service cache                  | `6379`                                                            |
| `edusharing_repository_service.config.cluster.enabled`                    | Enable repository service cluster                      | `${helm.edusharing_repository_cluster.enabled}`                   |
| `edusharing_repository_service.config.database.host`                      | Set host for repository service database               | `edusharing-repository-postgresql`                                |
| `edusharing_repository_service.config.database.port`                      | Set port for repository service database               | `5432`                                                            |
| `edusharing_repository_service.config.database.database`                  | Set repository service database                        | `repository`                                                      |
| `edusharing_repository_service.config.database.username`                  | Set repository service database username               | `repository`                                                      |
| `edusharing_repository_service.config.mongo.enabled`                      | Enable repository service mongo                        | `${helm.edusharing_repository_mongo.enabled}`                     |
| `edusharing_repository_service.config.mongo.host`                         | Set host for repository service mongo                  | `edusharing-repository-mongo`                                     |
| `edusharing_repository_service.config.mongo.port`                         | Set port for repository service mongo                  | `27017`                                                           |
| `edusharing_repository_service.config.mongo.database`                     | Set repository service mongo database                  | `repository`                                                      |
| `edusharing_repository_service.config.mongo.username`                     | Set repository service mongo username                  | `repository`                                                      |
| `edusharing_repository_service.config.search.elastic.enabled`             | Enable repository service elastic search               | `${helm.edusharing_repository_search_elastic_index.enabled}`      |
| `edusharing_repository_service.config.search.elastic.host`                | Set host for repository service elastic search         | `edusharing-repository-search-elastic-index`                      |
| `edusharing_repository_service.config.search.elastic.port`                | Set port for repository service elastic search         | `9200`                                                            |
| `edusharing_repository_service.config.search.solr.host`                   | Set host for repository service solr search            | `edusharing-repository-search-solr`                               |
| `edusharing_repository_service.config.search.solr.port`                   | Set port for repository service solr search            | `9200`                                                            |
| `edusharing_repository_service.config.transform.aio.host`                 | Set host for repository service transform_aio          | `edusharing-repository-transform-aio`                             |
| `edusharing_repository_service.config.transform.aio.port`                 | Set port for repository service transform_aio          | `8090`                                                            |
| `edusharing_repository_service.config.transform.es.host`                  | Set host for repository service transform_es           | `edusharing-repository-transform-es`                              |
| `edusharing_repository_service.config.transform.es.port`                  | Set port for repository service transform_es           | `8091`                                                            |
| `edusharing_repository_service.config.transform.server.enabled`           | Enable repository service transform server             | `${helm.edusharing_repository_transform.enabled}`                 |
| `edusharing_repository_service.config.transform.server.host`              | Set host for repository service transform server       | `edusharing-repository-transform`                                 |
| `edusharing_repository_service.config.transform.server.port`              | Set port for repository service transform server       | `8080`                                                            |
| `edusharing_repository_search_elastic_tracker.enabled`                    | Enable search repositories elastic tracker             | `${helm.edusharing_repository_search_elastic_tracker.enabled}`    |
| `edusharing_repository_search_elastic_tracker.config.repository.host`     | Set host of search repositories elastic tracker        | `edusharing-repository-service`                                   |
| `edusharing_repository_search_elastic_tracker.config.repository.port`     | Set port of search repositories elastic tracker        | `8080`                                                            |
| `edusharing_repository_search_elastic_tracker.config.search.elastic.host` | Set host of elastic search repository                  | `edusharing-repository-search-elastic-index`                      |
| `edusharing_repository_search_elastic_tracker.config.search.elastic.port` | Set port of elastic search repository                  | `9200`                                                            |
