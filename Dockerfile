# Ubuntu 24.04 LTS base image
FROM ubuntu:24.04

# Install packages
RUN apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends buildah ca-certificates curl git gpg jq less make nodejs npm openjdk-17-jdk openssl python3 python3-pip python3-virtualenv unzip vim wget yq zip && \
    rm -rf /var/lib/apt/lists/*

# Import additional root CA
ARG ROOT_CA_URL=
RUN test -z "${ROOT_CA_URL}" || (curl -sSLf -O --output-dir /usr/local/share/ca-certificates "${ROOT_CA_URL}" && update-ca-certificates)

# Download and install Google Cloud SDK
ARG CLOUDSDK_VERSION=494.0.0
RUN curl -sSLf -o /tmp/google-cloud-sdk.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${CLOUDSDK_VERSION}-linux-x86_64.tar.gz" && \
    tar -xf /tmp/google-cloud-sdk.tar.gz -C /opt && \
    rm -f /tmp/google-cloud-sdk.tar.gz && \
    /opt/google-cloud-sdk/install.sh --quiet --usage-reporting false && \
    ln -s /opt/google-cloud-sdk/path.bash.inc /etc/profile.d/google-cloud-sdk.sh

# Download and install Docker CLI
ARG DOCKER_VERSION=5:27.3.1
RUN curl -sSLf https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends docker-ce-cli=${DOCKER_VERSION}-* docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Download and install Helm
ARG HELM_VERSION=3.16.1
RUN curl -sSLf -o /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xf /tmp/helm.tar.gz -C /usr/local/bin --strip-components=1 linux-amd64/helm && \
    rm -f /tmp/helm.tar.gz

# Download and install kubectl
ARG KUBECTL_VERSION=1.31.1
RUN curl -sSLf -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# Download and install Maven
ARG MAVEN_VERSION=3.9.9
RUN curl -sSLf -o /tmp/maven.tar.gz "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" && \
    tar -xf /tmp/maven.tar.gz -C /usr/local/share && \
    rm -f /tmp/maven.tar.gz && \
    ln -s "/usr/local/share/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/local/bin/mvn

# Download and install Terraform
ARG TF_VERSION=1.9.6
RUN curl -sSLf -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip

# Download and install VS Code CLI
ARG VSCODE_CLI_VERSION=1.93.1
RUN VSCODE_CLI_URL=$(curl -sSLf "https://update.code.visualstudio.com/api/versions/${VSCODE_CLI_VERSION}/cli-alpine-x64/stable" | jq -r ".url") && \
    curl -sSLf -o /tmp/vscode-cli.tar.gz "${VSCODE_CLI_URL}" && \
    tar -xf /tmp/vscode-cli.tar.gz -C /usr/local/bin && \
    rm -f /tmp/vscode-cli.tar.gz

# Copy files
COPY entrypoint.sh /entrypoint.sh

# Create user
ARG USER_UID=1000
ARG USER_GID=100
RUN userdel ubuntu && rm -Rf /home/ubuntu && useradd -o -s /bin/bash -u ${USER_UID} -g ${USER_GID} -m vscode
USER ${USER_UID}
WORKDIR /home/vscode

# Startup
ENTRYPOINT ["/entrypoint.sh"]
