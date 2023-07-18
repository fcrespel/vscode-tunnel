# VS Code Tunnel Docker image

This container image includes the **VS Code CLI** along with useful build dependencies and tools (Git, Java, Maven, NodeJS, Python, Docker CLI, kubectl, helm, gcloud, ...).

When run without arguments, it will automatically start in [tunnel mode](https://code.visualstudio.com/docs/remote/tunnels) and await authentication. Make sure to check the logs if you are running it in the background and follow the displayed instructions.

After that you can connect to this container as a remote tunnel from anywhere on the web or desktop and develop in an isolated environment.

## Usage

The following commands can be used to start a tunnel from a machine with [Docker](https://docs.docker.com/engine/) installed.

```
# Create a dedicated volume for persistence
docker volume create vscode-tunnel

# Start tunnel in the background
docker run -d --name vscode-tunnel -v vscode-tunnel:/home/vscode ghcr.io/fcrespel/vscode-tunnel:master

# Check the logs for authentication and connection instructions
docker logs -f vscode-tunnel

# Stop tunnel after usage
docker stop vscode-tunnel

# Start again existing tunnel
docker start vscode-tunnel

# Delete container and data
docker stop vscode-tunnel
docker rm vscode-tunnel
docker volume rm vscode-tunnel
```

As an alternative, you may also want to use a [Docker Compose](https://docs.docker.com/compose/) file such as the following.

```
services:
  vscode-tunnel:
    image: ghcr.io/fcrespel/vscode-tunnel:master
    restart: unless-stopped
    hostname: vscode-tunnel
    volumes:
      - vscode-tunnel:/home/vscode
volumes:
  vscode-tunnel:
```

## Build arguments

The following arguments can be used during the build phase to configure the image.

| Argument | Description | Default value |
| -------- | ----------- | ------------- |
| CLOUDSDK_VERSION | Google Cloud SDK version to install | 434.0.0 |
| HELM_VERSION | Helm version to install | 3.11.3 |
| KUBECTL_VERSION | kubectl version to install | 1.27.1 |
| MAVEN_VERSION | Maven version to install | 3.8.8 |
| ROOT_CA_URL | Additional root certificate authority URL to install | |
| TF_VERSION | Terraform version to install | 1.4.6 |
| USER_GID | Group ID of the user to create | 100 |
| USER_UID | User ID of the user to create | 1000 |
| VSCODE_VERSION | VS Code CLI version to install | 1.80.1 |

## Volumes

The following container paths can be used to mount a dedicated volume.

| Path | Description |
| ---- | ----------- |
| /home/vscode | User configuration and data |
