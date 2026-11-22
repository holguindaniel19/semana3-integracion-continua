# Jenkins oficial (LTS) + cliente de Docker y plugins necesarios.
FROM jenkins/jenkins:lts

USER root

# Cliente de Docker, Docker Compose y Buildx (Jenkins los usa para hablar con el Docker del equipo)
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y docker-ce-cli docker-compose-plugin docker-buildx-plugin \
 && rm -rf /var/lib/apt/lists/*

USER jenkins

# Plugins: Git, GitHub, Pipeline, Docker Pipeline, Credentials Binding y vista de etapas
RUN jenkins-plugin-cli --plugins git github workflow-aggregator docker-workflow credentials-binding pipeline-stage-view
