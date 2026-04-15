## Parameters

### Global parameters

| Name                                    | Description                          | Value   |
| --------------------------------------- | ------------------------------------ | ------- |
| `global.cluster.istio.enabled`          | Enable Istio Service mesh            | `false` |
| `global.metrics.prometheus.enabled`     | Enable global prometheus metrics     | `false` |
| `global.metrics.prometheus.retention`   | Set prometheus metric retention time | `1w`    |
| `global.metrics.scrape.interval`        | Set prometheus scrape interval       | `10s`   |
| `global.metrics.scrape.timeout`         | Set prometheus scrape timeout        | `10s`   |
| `global.metrics.servicemonitor.enabled` | Enable metrics service monitor       | `false` |

### Local parameters

| Name                                                                                           | Description                                        | Value                                                        |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| `nameOverride`                                                                                 | Override name                                      | `edusharing`                                                 |
| `image.pullSecrets`                                                                            | How to pull secrets                                | `[]`                                                         |
| `edusharing_rediscluster.enabled`                                                              | Enable edusharing rediscluster                     | `true`                                                       |
| `edusharing_rediscluster.nameOverride`                                                         | Override edusharing rediscluster name              | `edusharing-rediscluster`                                    |
| `edusharing_rediscluster.image.name`                                                           | Set rediscluster image name                        | `${docker.edu_sharing.community.common.redis-cluster.name}`  |
| `edusharing_rediscluster.image.tag`                                                            | Set rediscluster image tag                         | `${docker.edu_sharing.community.common.redis-cluster.tag}`   |
| `edusharing_rediscluster.service.port.api`                                                     | Set port for rediscluster service api              | `6379`                                                       |
| `edusharing_rediscluster.init.permission.image.name`                                           | Set rediscluster init image name                   | `${docker.edu_sharing.community.common.minideb.name}`        |
| `edusharing_rediscluster.init.permission.image.tag`                                            | Set rediscluster init image tag                    | `${docker.edu_sharing.community.common.minideb.tag}`         |
| `edusharing_rediscluster.init.sysctl.image.name`                                               | Set rediscluster init sysctl image name            | `${docker.edu_sharing.community.common.minideb.name}`        |
| `edusharing_rediscluster.init.sysctl.image.tag`                                                | Set rediscluster init sysctl image tag             | `${docker.edu_sharing.community.common.minideb.tag}`         |
| `edusharing_rediscluster.sidecar.metrics.image.name`                                           | Set rediscluster sidecar metrics image name        | `${docker.edu_sharing.community.common.redis.exporter.name}` |
| `edusharing_rediscluster.sidecar.metrics.image.tag`                                            | Set rediscluster sidecar metrics image tag         | `${docker.edu_sharing.community.common.redis.exporter.tag}`  |
| `edusharing_repository.enabled`                                                                | Enable repository                                  | `true`                                                       |
| `edusharing_repository.edusharing_repository_rediscluster.enabled`                             | Enable repository rediscluster                     | `false`                                                      |
| `edusharing_repository.edusharing_repository_service.nameOverride`                             | Override repository service name                   | `edusharing-repository-service`                              |
| `edusharing_repository.edusharing_repository_service.service.port.api.internal`                | Set internal repository service api port           | `8080`                                                       |
| `edusharing_repository.edusharing_repository_service.config.cache.host`                        | Set host for repository service redis config cache | `edusharing-rediscluster`                                    |
| `edusharing_repository.edusharing_repository_service.config.cache.port`                        | Set port for repository service redis config cache | `6379`                                                       |
| `edusharing_services_connector.enabled`                                                        | Enable connector service                           | `${helm.edusharing_services_connector.enabled}`              |
| `edusharing_services_connector.edusharing_services_connector_rediscluster.enabled`             | Enable rediscluster connector service              | `false`                                                      |
| `edusharing_services_connector.edusharing_services_connector_service.config.cache.host`        | Set host for connector service cache               | `edusharing-rediscluster`                                    |
| `edusharing_services_connector.edusharing_services_connector_service.config.cache.port`        | Set port for connector service cache               | `6379`                                                       |
| `edusharing_services_connector.edusharing_services_connector_service.config.repository.host`   | Set host for connector service repository          | `edusharing-repository-service`                              |
| `edusharing_services_connector.edusharing_services_connector_service.config.repository.port`   | Set port for connector service repository          | `8080`                                                       |
| `edusharing_services_rendering.enabled`                                                        | Enable rendering service                           | `${helm.edusharing_services_rendering.enabled}`              |
| `edusharing_services_rendering.edusharing_services_rendering_rediscluster.enabled`             | Enable rediscluster rendering service              | `false`                                                      |
| `edusharing_services_rendering.edusharing_services_rendering_service.config.cache.host`        | Set host for rendering service cache               | `edusharing-rediscluster`                                    |
| `edusharing_services_rendering.edusharing_services_rendering_service.config.cache.port`        | Set port for rendering service cache               | `6379`                                                       |
| `edusharing_services_rendering.edusharing_services_rendering_service.config.repository.host`   | Set host for rendering service repository          | `edusharing-repository-service`                              |
| `edusharing_services_rendering.edusharing_services_rendering_service.config.repository.port`   | Set port for rendering service repository          | `8080`                                                       |
| `edusharing_services_rendering2.enabled`                                                       | Enable rendering service                           | `${helm.edusharing_services_rendering2.enabled}`             |
| `edusharing_services_rendering2.edusharing_services_rendering2_rediscluster.enabled`           | Enable rediscluster rendering service              | `false`                                                      |
| `edusharing_services_rendering2.edusharing_services_rendering2_service.config.redis.host`      | Set host for rendering service cache               | `edusharing-rediscluster`                                    |
| `edusharing_services_rendering2.edusharing_services_rendering2_service.config.redis.port`      | Set port for rendering service cache               | `6379`                                                       |
| `edusharing_services_rendering2.edusharing_services_rendering2_service.config.repository.host` | Set host for rendering service repository          | `edusharing-repository-service`                              |
| `edusharing_services_rendering2.edusharing_services_rendering2_service.config.repository.port` | Set port for rendering service repository          | `8080`                                                       |
