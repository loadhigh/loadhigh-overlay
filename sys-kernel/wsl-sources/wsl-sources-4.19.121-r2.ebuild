# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
ETYPE="sources"
K_WANT_GENPATCHES="extras experimental"
K_GENPATCHES_VER="129"

inherit kernel-2
detect_version
detect_arch

KEYWORDS="amd64 arm64"
HOMEPAGE="https://github.com/microsoft/WSL2-Linux-Kernel"
IUSE="experimental"

DESCRIPTION="The source for the Linux kernel used in Windows Subsystem for Linux 2 (WSL2) for the ${KV_MAJOR}.${KV_MINOR} kernel tree"

KERNEL_URI="https://github.com/microsoft/WSL2-Linux-Kernel/archive/${PV}-microsoft-standard.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

universal_unpack() {
	mkdir -p "${WORKDIR}/linux-${KV_FULL}"
	tar xf "${DISTDIR}/${OKV}-microsoft-standard.tar.gz" -C "${WORKDIR}/linux-${KV_FULL}" --strip-components=1
	cd "${S}"
}

src_install() {
	kernel-2_src_install
	insinto "/usr/src/linux-${KV_FULL}/Microsoft"
	newins "${FILESDIR}/config-hv-${OKV}.gz" config-hv.gz
	gunzip "${D}/usr/src/linux-${KV_FULL}/Microsoft/config-hv.gz" || die
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}