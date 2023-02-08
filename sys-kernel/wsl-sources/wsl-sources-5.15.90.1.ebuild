# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
ETYPE="sources"
K_WANT_GENPATCHES="extras experimental"
K_GENPATCHES_VER="94"

inherit kernel-2
detect_version
detect_arch

MSV="${CKV}"

KEYWORDS="amd64 arm64"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"
IUSE="experimental"

DESCRIPTION="Linux kernel used WSL2 for the ${KV_MAJOR}.${KV_MINOR} kernel tree"

KERNEL_URI="https://github.com/microsoft/WSL2-Linux-Kernel/archive/linux-msft-wsl-${MSV}.tar.gz -> linux-msft-${MSV}.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

UNIPATCH_LIST_DEFAULT=""

S="${WORKDIR}/linux-${MSV}-wsl"

# Override universal_unpack()
universal_unpack() {
	cd "${WORKDIR}"
	unpack linux-msft-${MSV}.tar.gz
	mv WSL2-Linux-Kernel-linux-msft-wsl-${MSV} linux-${MSV}-wsl || die
	cd "${S}"
}
