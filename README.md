# edu_sharing-projects-community

The edu-sharing open-source project started in 2007 to develop networked E-Learning environments 
for managing and sharing educational contents inter-organisationally.

Documentation
-------------
More information can be found on the [homepage](http://www.edu-sharing.com).

Or visit the edu-sharing [documentation](http://docs.edu-sharing.com/confluence/edp).

Where can I get the latest release?
-----------------------------------
You can download source and binaries from our [artifact repository](https://artifacts.edu-sharing.com).

Contributing
------------
For contribution on a regular basis please visit our [community site](http://edu-sharing-network.org/?lang=en).

Security Issues
---------------
If you found something which might could be a vulnerability or a security issue, 
please contact us first instead of making a public issue. 
This can help us tracking down the issue first and may provide patches beforehand.

Please provide such concerns via mail to security@edu-sharing.com

Thanks!

# Maven Git Workflow

Maven artifacts, Docker images, Helm charts, etc., are versioned based on the Git branch name or tag.  
From `maven/fixes/10.0`, the artifact is built with the version `<artifactid>:maven-fixes-10.0-SNAPSHOT`.


Feature branches are treated specially.  
Feature branches following the pattern `maven/feature/<version>-My-Fancy-Feature` also produce Maven artifacts with the version  
`<artifactid>:maven-fixes-<version>-SNAPSHOT`.  
For example, from `maven/feature/10.0-My-Fancy-Feature`, the artifact will be built with the version  
`<artifactid>:maven-fixes-10.0-SNAPSHOT`.

This allows feature branches to be created without requiring all projects to use the same branch name.

To avoid cross-project artifact conflicts between different feature branches, the environment variable `PROJECT_NAME` can be used  
to prefix the artifact for each customer project.  
In this case, the artifact will be generated as `<artifactid>:<PROJECT_NAME>maven-fixes-<version>-SNAPSHOT`.

**Example:**  
`PROJECT_NAME=community-`  
From `maven/feature/10.0-My-Fancy-Feature`, the artifact will be built with the version  
`<artifactid>:community-maven-fixes-10.0-SNAPSHOT`.

It is important that all projects are built using the same `PROJECT_NAME`.

This is handled by edu-dev-tools ij command for you

Additionally, the Maven property `project.version.base` is overridden to always point to the underlying  
`maven-fixes-<version>-SNAPSHOT` version.  
This can be handy for external managed projects like `rendering-service-2`.
