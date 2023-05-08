# Ubuntu 22.04 LTS base image
FROM ubuntu:22.04

# Install packages
RUN apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends buildah ca-certificates curl git gpg jq less make nodejs npm openjdk-8-jdk openjdk-11-jdk openssl python3 python3-pip python3-virtualenv unzip vim wget zip && \
    rm -rf /var/lib/apt/lists/*

# Import additional root CA
ARG ROOT_CA_URL=
RUN test -z "${ROOT_CA_URL}" || (curl -sSLf -O --output-dir /usr/local/share/ca-certificates "${ROOT_CA_URL}" && update-ca-certificates)

# Download and install Maven
ARG MAVEN_VERSION=3.8.8
RUN curl -sSLf -o /tmp/maven.tar.gz "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" && \
    tar -xf /tmp/maven.tar.gz -C /usr/local/share && \
    rm -f /tmp/maven.tar.gz && \
    ln -s "/usr/local/share/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/local/bin/mvn

# Download and install Terraform
ARG TF_VERSION=1.4.6
RUN curl -sSLf -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip

# Download and install kubectl
ARG KUBECTL_VERSION=1.27.1
RUN curl -sSLf -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# Download and install Helm
ARG HELM_VERSION=3.11.3
RUN curl -sSLf -o /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xf /tmp/helm.tar.gz -C /usr/local/bin --strip-components=1 linux-amd64/helm && \
    rm -f /tmp/helm.tar.gz

# Download and install VS Code CLI
RUN curl -sSLf -o /tmp/vscode-cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" && \
    tar -xf /tmp/vscode-cli.tar.gz -C /usr/local/bin && \
    rm -f /tmp/vscode-cli.tar.gz

# Copy files
COPY entrypoint.sh /entrypoint.sh

# Create user
ARG USER_UID=1000
ARG USER_GID=100
RUN useradd -s /bin/bash -u ${USER_UID} -g ${USER_GID} -m vscode
USER ${USER_UID}
WORKDIR /home/vscode

# Startup
ENTRYPOINT ["/entrypoint.sh"]
