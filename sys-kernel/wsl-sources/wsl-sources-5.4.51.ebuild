# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
ETYPE="sources"
K_WANT_GENPATCHES="extras experimental"
K_GENPATCHES_VER="52"

inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64 ~arm64"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"
IUSE="experimental"

DESCRIPTION="Linux kernel used WSL2 for the ${KV_MAJOR}.${KV_MINOR} kernel tree"

KERNEL_URI="https://github.com/microsoft/WSL2-Linux-Kernel/archive/linux-msft-${OKV}.tar.gz -> linux-msft-${OKV}.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

# Override universal_unpack()
universal_unpack() {
	cd "${WORKDIR}"
	unpack linux-msft-${OKV}.tar.gz
	mv WSL2-Linux-Kernel-linux-msft-${OKV} linux-${KV_FULL} || die
	cd "${WORKDIR}/linux-${KV_FULL}/Microsoft" || die
	unpack "${FILESDIR}"/config-hv-${OKV}.xz
	mv config-hv-${OKV} config-hv || die
	cd "${S}"
}
