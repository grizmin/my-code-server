# Use Ubuntu as the base image
FROM ubuntu:latest

# Set Visual Studio Code connection token
ENV VSCODE_CONNECTION_TOKEN=my_default_token
ENV VSCODE_PORT=8586
ENV ROOT_PASSWORD=toor

# Set the root password for the IDE system; Make sure to change this to a secure password if you are exposing this container to the internet
RUN echo "root:${ROOT_PASSWORD}" | chpasswd

# Install necessary packages
RUN apt-get update && apt-get install -y software-properties-common apt-transport-https wget && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Add the Microsoft GPG key
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg

# Add the Visual Studio Code repository
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list

# Install needed packages on your IDE system
RUN apt-get update && apt-get install -y code
RUN apt-get -y install sudo -y \
    nano \
    git \
    curl \
    wget \
    unzip \
    npm \
    ssh && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Create a non-root user
RUN useradd -m vscodeuser -s /bin/bash -G nobody,sudo -u 99

# Switch to the non-root user
USER vscodeuser

# Set the home directory for the non-root user
ENV HOME /home/vscodeuser

# Install the GitHub Copilot extension
# RUN code --install-extension GitHub.copilot-chat

# Expose the port for VS Code
EXPOSE $VSCODE_PORT

# Start Visual Studio Code on port 8585 from anywhere (0.0.0.0)
CMD code serve-web --host 0.0.0.0 --port $VSCODE_PORT --user-data-dir "${HOME}" --accept-server-license-terms --connection-token $VSCODE_CONNECTION_TOKEN