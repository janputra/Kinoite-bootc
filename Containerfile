# Allow build scripts to be referenced without being copied into the final image
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"

FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/kinoite-main:42

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10


# Enable COPR repo for kernel-cachyos
RUN dnf5 -y copr enable bieszczaders/kernel-cachyos
RUN dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# Enable RPM Fusion (free + nonfree)
RUN dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-42.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-42.noarch.rpm

# Install kernel-cachyos and NVIDIA
RUN dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra && dnf5 install -y \
    kernel-cachyos \
    kernel-cachyos-core \
    kernel-cachyos-modules \
    kernel-cachyos-devel \
    kernel-headers \
    uksmd \ 
    scx-scheds  
    

# Install NVIDIA driver
RUN rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia

RUN akmods --force --kernels "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos-devel)"  && dracut --regenerate-all --force

RUN dnf5 clean all && \
    rm -rf /tmp/* || true

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint