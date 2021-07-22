# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
ETYPE="sources"
K_WANT_GENPATCHES="extras experimental"
K_GENPATCHES_VER="47"

inherit kernel-2
detect_version
detect_arch

MSV="${OKV}.3"

KEYWORDS="~amd64 ~arm64"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"
IUSE="experimental"

DESCRIPTION="Linux kernel used WSL2 for the ${KV_MAJOR}.${KV_MINOR} kernel tree"

KERNEL_URI="https://github.com/microsoft/WSL2-Linux-Kernel/archive/linux-msft-wsl-${MSV}.tar.gz -> linux-msft-${OKV}.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

# Override universal_unpack()
universal_unpack() {
	cd "${WORKDIR}"
	unpack linux-msft-${OKV}.tar.gz
	mv WSL2-Linux-Kernel-linux-msft-wsl-${MSV} linux-${KV_FULL} || die
	cd "${WORKDIR}/linux-${KV_FULL}/Microsoft" || die
	unpack "${FILESDIR}"/config-hv-${OKV}.bz2
	mv config-hv-${OKV} config-hv || die
	cd "${S}"
}
