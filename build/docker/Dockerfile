FROM fedora:latest

# Install build dependencies
RUN dnf install -y \
    livecd-tools \
    util-linux \
    git \
    && dnf clean all

WORKDIR /maleo-os

ENTRYPOINT ["/bin/bash"]
