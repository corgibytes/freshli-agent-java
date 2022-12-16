FROM mcr.microsoft.com/devcontainers/ruby:0-3.0-bullseye

# ensure that curl is installed
RUN sudo apt-get update -y && \
    sudo apt-get install -y curl

# install the CycloneDX CLI
RUN curl -L -o /usr/local/bin/cyclonedx https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.24.2/cyclonedx-linux-x64 && \
    chmod a+x /usr/local/bin/cyclonedx
