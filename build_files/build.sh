#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1









dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra 
dnf5 -y install kernel-cachyos kernel-cachyos-devel-matched libcap-ng libcap-ng-devel procps-ng procps-ng-devel uksmd scx-scheds
# this installs a package from fedora repos
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf5 install -y screen virt-manager samba fcitx5 fcitx5-hangul code
dnf5 install -y steam mangohud gamemode 
dnf5 install -y plasma-workspace-x11 btop neovim fastfetch git-cola
dnf5 install -y tuned-utils tuned-gtk tuned-profiles-atomic tuned-profiles-cpu-partitioning 

dnf5 install -y install akmod-nvidia xorg-x11-drv-nvidia

dnf5 -y copr disable bieszczaders/kernel-cachyos
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
sudo systemctl enable scx.service